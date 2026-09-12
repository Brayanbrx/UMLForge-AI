import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/api.dart';
import '../data/local_store.dart';
import '../data/repository.dart';
import '../domain/schema.dart';

class AppModel extends ChangeNotifier {
  AppSchema schema;
  final ApiClient api;
  final SessionStore sessions;
  Repository? repository;
  ResourceSpec selected;
  List<Map<String, dynamic>> rows = [];
  List<Map<String, Object?>> queue = [];
  String message = '';
  bool busy = false;
  Object? _syncRun;
  bool _disposed = false;
  Timer? timer;
  Session? get session => api.session;
  AppModel(this.schema, this.api, this.sessions)
    : selected = schema.resources.first {
    api.sessions = sessions;
  }
  Future<void> restore() async {
    unawaited(api.flushLogouts());
    final session = await sessions.restore();
    if (session != null) await _open(session);
  }

  Future<void> login(String url, String username, String password) async {
    final session = await api.login(url, username, password);
    await sessions.save(session);
    await _open(session);
  }

  Future<void> _open(Session session) async {
    final nextSchema = session.contract == null
        ? schema
        : AppSchema.fromRemote({
            'protocolVersion': 1,
            'contract': session.contract,
          });
    // Preserve queues from the earlier paired APK when connecting to its original contract.
    final bundled = await AppSchema.load();
    final scopeHash = nextSchema.fingerprint == bundled.fingerprint
        ? '__SCHEMA_HASH__'
        : nextSchema.fingerprint;
    timer?.cancel();
    _syncRun = null;
    await repository?.local.close();
    api.session = session;
    schema = nextSchema;
    selected = schema.resources.first;
    repository = Repository(
      await LocalStore.open('${session.url}|${session.username}|$scopeHash'),
      api,
      schema,
    );
    await refreshLocal();
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(sync()),
    );
    unawaited(sync());
  }

  Future<void> logout() async {
    if (busy) throw StateError('Espera a que termine la operacion');
    timer?.cancel();
    _syncRun = null;
    if (session != null) await sessions.queueLogout(session!);
    // Invalidate in-flight requests before awaiting secure-storage deletion.
    api.session = null;
    await sessions.clear();
    await repository?.local.close();
    repository = null;
    api.session = null;
    rows = [];
    queue = [];
    notifyListeners();
    unawaited(api.flushLogouts());
  }

  Future<void> refreshLocal() async {
    final repo = repository;
    if (repo == null || _disposed) return;
    final resource = selected;
    final nextRows = await repo.local.rows(resource.resource);
    final nextQueue = await repo.local.queue();
    if (_disposed ||
        !identical(repository, repo) ||
        !identical(selected, resource))
      return;
    rows = nextRows;
    queue = nextQueue;
    notifyListeners();
  }

  Future<void> select(ResourceSpec value) async {
    selected = value;
    await refreshLocal();
  }

  Future<void> sync() async {
    final repo = repository;
    if (busy || _syncRun != null || repo == null || _disposed) return;
    final run = Object();
    _syncRun = run;
    var locked = false;
    bool current() =>
        !_disposed && identical(repository, repo) && identical(_syncRun, run);
    try {
      // A slow/unreachable server must not prevent local agent/form writes.
      // Lock editing only after the contract is reachable and the outbox is sent.
      await api.verifyContract(schema);
      if (!current() || busy) return;
      locked = true;
      busy = true;
      notifyListeners();
      await repo.synchronize();
      if (current()) message = 'Actualizado';
    } catch (error) {
      if (current())
        message = error is ApiFailure
            ? error.message
            : error is FormatException
            ? error.message
            : 'Sin conexion disponible. Los datos y cambios se conservan en este dispositivo.';
    } finally {
      if (current()) {
        _syncRun = null;
        if (locked) busy = false;
        await refreshLocal();
      }
    }
  }

  Future<void> acceptServer(String operationId) async {
    final repo = repository;
    if (busy || repo == null || _disposed) {
      throw StateError('Espera a que termine la operacion');
    }
    busy = true;
    notifyListeners();
    try {
      await repo.acceptServer(operationId);
    } finally {
      if (!_disposed && identical(repository, repo)) {
        busy = false;
        await refreshLocal();
      }
    }
  }

  Future<void> save(
    ResourceSpec resource,
    Map<String, dynamic> data, {
    required bool create,
    Map<String, dynamic>? expected,
  }) async {
    if (busy) throw StateError('Espera a que termine la sincronizacion');
    await repository!.save(resource, data, create: create, expected: expected);
    await refreshLocal();
    unawaited(sync());
  }

  Future<void> delete(
    ResourceSpec resource,
    dynamic id, {
    Map<String, dynamic>? expected,
  }) async {
    if (busy) throw StateError('Espera a que termine la sincronizacion');
    await repository!.delete(resource, id, expected: expected);
    await refreshLocal();
    unawaited(sync());
  }

  @override
  void dispose() {
    _disposed = true;
    _syncRun = null;
    timer?.cancel();
    api.close();
    unawaited(repository?.local.close());
    super.dispose();
  }
}
