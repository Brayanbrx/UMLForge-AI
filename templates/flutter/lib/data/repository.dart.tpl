import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../domain/schema.dart';
import 'api.dart';
import 'local_store.dart';

class Repository {
  final LocalStore local;
  final RemoteApi remote;
  final AppSchema schema;
  bool _syncing = false;
  Repository(this.local, this.remote, this.schema);
  Future<void> save(
    ResourceSpec resource,
    Map<String, dynamic> dto, {
    required bool create,
    Map<String, dynamic>? expected,
  }) async {
    resource.validate(dto);
    await _enqueue(
      resource,
      dto[resource.primaryKey],
      create ? 'POST' : 'PUT',
      dto,
      expected,
    );
  }

  Future<void> delete(
    ResourceSpec resource,
    dynamic id, {
    Map<String, dynamic>? expected,
  }) => _enqueue(resource, id, 'DELETE', null, expected);
  Future<void> _enqueue(
    ResourceSpec resource,
    dynamic id,
    String method,
    Map<String, dynamic>? dto,
    Map<String, dynamic>? expected,
  ) async {
    if (_syncing) throw StateError('Espera a que termine la sincronizacion');
    await local.db.transaction((tx) async {
      final args = [resource.resource, id.toString()];
      final pending = await tx.query(
        'outbox',
        where: 'resource=? AND id=?',
        whereArgs: args,
      );
      if (pending.isNotEmpty &&
          (pending.first['attempted'] != 0 ||
              pending.first['status'] == 'conflict'))
        throw StateError(
          'Este registro tiene un cambio pendiente. Sincronizalo o resuelve su conflicto antes de editarlo otra vez.',
        );
      final old = await tx.query(
        'records',
        where: 'resource=? AND id=?',
        whereArgs: args,
      );
      if (method == 'POST' && old.isNotEmpty)
        throw StateError('La clave ya existe localmente.');
      if (method != 'POST' && old.isEmpty)
        throw StateError('El registro ya no existe localmente.');
      if (expected != null &&
          (old.isEmpty ||
              !mapEquals(
                expected,
                Map<String, dynamic>.from(
                  jsonDecode(old.first['payload'] as String),
                ),
              )))
        throw StateError(
          'El registro cambio mientras lo revisabas. Abrelo de nuevo antes de guardar.',
        );
      final base = old.isEmpty ? null : old.first['server_payload'];
      if (pending.isNotEmpty) {
        final prior = pending.single;
        if (prior['method'] == 'DELETE')
          throw StateError('El registro ya esta marcado para eliminar');
        if (prior['method'] == 'POST' && method == 'DELETE') {
          await tx.delete(
            'outbox',
            where: 'operation_id=?',
            whereArgs: [prior['operation_id']],
          );
          await tx.delete(
            'records',
            where: 'resource=? AND id=?',
            whereArgs: args,
          );
          return;
        }
        await tx.update(
          'outbox',
          {
            'method': prior['method'] == 'POST' ? 'POST' : method,
            'payload': dto == null ? null : jsonEncode(dto),
          },
          where: 'operation_id=?',
          whereArgs: [prior['operation_id']],
        );
        await tx.update(
          'records',
          {
            'payload': jsonEncode(
              dto ?? jsonDecode(old.first['payload'] as String),
            ),
            'deleted': method == 'DELETE' ? 1 : 0,
          },
          where: 'resource=? AND id=?',
          whereArgs: args,
        );
        return;
      }
      await tx.insert('outbox', {
        'operation_id': const Uuid().v4(),
        'resource': resource.resource,
        'id': id.toString(),
        'method': method,
        'payload': dto == null ? null : jsonEncode(dto),
        'base': base,
      });
      await tx.insert('records', {
        'resource': resource.resource,
        'id': id.toString(),
        'payload': jsonEncode(
          dto ?? jsonDecode(old.first['payload'] as String),
        ),
        'server_payload': base,
        'deleted': method == 'DELETE' ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Original operation ID, data and base are immutable across every retry.
  Future<void> synchronize() async {
    if (_syncing) return;
    _syncing = true;
    try {
      for (final entry in await local.queue()) {
        if (entry['status'] == 'conflict') break;
        final resource = schema.resource(entry['resource'] as String);
        final body = <String, dynamic>{
          'operationId': entry['operation_id'],
          'resource': entry['resource'],
          'method': entry['method'],
          'id': resource.key.parse(entry['id'] as String),
          'data': entry['payload'] == null
              ? null
              : jsonDecode(entry['payload'] as String),
          'base': entry['base'] == null
              ? null
              : jsonDecode(entry['base'] as String),
        };
        dynamic response;
        try {
          await local.db.update(
            'outbox',
            {'attempted': 1},
            where: 'operation_id=?',
            whereArgs: [entry['operation_id']],
          );
          response = await remote.request('POST', '/mobile-sync', body);
        } on ApiFailure catch (error) {
          if ([400, 404, 409, 422].contains(error.status)) {
            await local.db.update(
              'outbox',
              {'status': 'conflict', 'message': error.message},
              where: 'operation_id=?',
              whereArgs: [entry['operation_id']],
            );
          }
          rethrow;
        }
        if (response is! Map ||
            response['operationId'] != entry['operation_id'] ||
            !response.containsKey('data'))
          throw StateError('Confirmacion de sincronizacion invalida');
        await local.db.transaction((tx) async {
          final args = [entry['resource'], entry['id']];
          if (entry['method'] == 'DELETE') {
            await tx.delete(
              'records',
              where: 'resource=? AND id=?',
              whereArgs: args,
            );
          } else {
            final dto = Map<String, dynamic>.from(response['data']);
            if (dto[resource.primaryKey].toString() != entry['id'])
              throw StateError('Identificador remoto inesperado');
            await tx.update(
              'records',
              {
                'payload': jsonEncode(dto),
                'server_payload': jsonEncode(dto),
                'deleted': 0,
              },
              where: 'resource=? AND id=?',
              whereArgs: args,
            );
          }
          await tx.delete(
            'outbox',
            where: 'operation_id=?',
            whereArgs: [entry['operation_id']],
          );
        });
      }
      for (final resource in schema.resources) {
        final result = await remote.request('GET', resource.path);
        if (result is! List) throw StateError('Lista remota invalida');
        await local.db.transaction((tx) async {
          final pending = (await tx.query(
            'outbox',
            columns: ['id'],
            where: 'resource=?',
            whereArgs: [resource.resource],
          )).map((r) => r['id']).toSet();
          final ids = <String>{};
          for (final row in result) {
            final dto = Map<String, dynamic>.from(row);
            final id = dto[resource.primaryKey];
            if (id == null) throw StateError('Registro sin clave');
            ids.add(id.toString());
            if (!pending.contains(id.toString()))
              await tx.insert('records', {
                'resource': resource.resource,
                'id': id.toString(),
                'payload': jsonEncode(dto),
                'server_payload': jsonEncode(dto),
                'deleted': 0,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          for (final row in await tx.query(
            'records',
            where: 'resource=?',
            whereArgs: [resource.resource],
          )) {
            if (!ids.contains(row['id']) && !pending.contains(row['id']))
              await tx.delete(
                'records',
                where: 'resource=? AND id=?',
                whereArgs: [resource.resource, row['id']],
              );
          }
        });
      }
    } finally {
      _syncing = false;
    }
  }

  /// Only definitive conflicts may be discarded; a network timeout is not proof of failure.
  Future<void> acceptServer(String operationId) async {
    if (_syncing) throw StateError('Espera a que termine la sincronizacion');
    final matches = await local.db.query(
      'outbox',
      where: 'operation_id=? AND status=?',
      whereArgs: [operationId, 'conflict'],
    );
    if (matches.isEmpty)
      throw StateError('El cambio aun no tiene un rechazo definitivo');
    final entry = matches.single;
    final resource = schema.resource(entry['resource'] as String);
    dynamic dto;
    try {
      dto = await remote.request(
        'GET',
        '${resource.path}/${Uri.encodeComponent(entry['id'] as String)}',
      );
    } on ApiFailure catch (error) {
      if (error.status != 404) rethrow;
    }
    await local.db.transaction((tx) async {
      if (dto == null) {
        await tx.delete(
          'records',
          where: 'resource=? AND id=?',
          whereArgs: [entry['resource'], entry['id']],
        );
      } else {
        await tx.update(
          'records',
          {
            'payload': jsonEncode(dto),
            'server_payload': jsonEncode(dto),
            'deleted': 0,
          },
          where: 'resource=? AND id=?',
          whereArgs: [entry['resource'], entry['id']],
        );
      }
      await tx.delete(
        'outbox',
        where: 'operation_id=?',
        whereArgs: [operationId],
      );
    });
  }
}
