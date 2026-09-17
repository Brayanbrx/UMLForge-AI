import 'dart:convert';
import 'schema.dart';
import 'package:uuid/uuid.dart';

/// Quita el bloque de codigo Markdown que algunos modelos ponen alrededor del
/// JSON aunque se les pida lo contrario. Solo eso: cualquier otro texto extra
/// sigue siendo una respuesta fuera del contrato.
String stripCodeFence(String response) {
  final text = response.trim();
  final match = RegExp(
    r'^```[a-zA-Z]*\s*([\s\S]*?)\s*```$',
  ).firstMatch(text);
  return match == null ? text : match.group(1)!.trim();
}

class Proposal {
  final String action, resource;
  final dynamic id;
  final Map<String, dynamic>? data;
  Proposal(this.action, this.resource, this.id, this.data);
  factory Proposal.parse(String response, AppSchema schema) {
    final dynamic value;
    try {
      value = jsonDecode(stripCodeFence(response));
    } on FormatException {
      throw const FormatException(
        'La respuesta del modelo no es JSON. Repite la instruccion o cambia de modelo.',
      );
    }
    if (value is! Map ||
        value.keys.any(
          (k) => !['action', 'resource', 'id', 'data', 'question'].contains(k),
        ))
      throw FormatException('Respuesta local fuera del contrato');
    if (value['question'] != null)
      throw FormatException(value['question'].toString());
    if (!['CREATE', 'UPDATE', 'DELETE', 'LIST'].contains(value['action']) ||
        value['resource'] is! String)
      throw FormatException('Accion o recurso invalido');
    final resource = schema.resource(value['resource']);
    final data = value['data'] == null
        ? null
        : Map<String, dynamic>.from(value['data']);
    if (['CREATE', 'UPDATE'].contains(value['action'])) {
      if (data == null) throw FormatException('Faltan los datos del registro');
      if (value['action'] == 'CREATE' &&
          resource.key.javaType == 'UUID' &&
          data[resource.primaryKey] == null)
        data[resource.primaryKey] = const Uuid().v4();
      resource.validate(data);
    }
    if (['UPDATE', 'DELETE'].contains(value['action']) && value['id'] == null)
      throw FormatException('Falta la clave del registro');
    if (value['action'] == 'UPDATE' &&
        value['id'] != data?[resource.primaryKey])
      throw FormatException('Las claves no coinciden');
    return Proposal(value['action'], resource.resource, value['id'], data);
  }
  Map<String, dynamic> toJson() => {
    'action': action,
    'resource': resource,
    'id': id,
    'data': data,
  };
}
