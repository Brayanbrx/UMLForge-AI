import 'dart:convert';
import 'assistant_ports.dart';
import 'assistant_protocol.dart';
import 'assistant_session.dart';

class AssistantOutcome {
  final String kind, text;
  final Map<String, dynamic>? draft;
  final int steps;
  const AssistantOutcome(this.kind, this.text, this.steps, {this.draft});
}

class AssistantRunner {
  final AssistantCompletion complete;
  final AssistantTools tools;
  final AssistantSession session;
  final void Function() checkActive;
  final void Function(String) progress;
  final int maxSteps, maxRepairs;
  AssistantRunner({
    required this.complete,
    required this.tools,
    required this.session,
    required this.checkActive,
    required this.progress,
    this.maxSteps = 8,
    this.maxRepairs = 2,
  });

  Future<AssistantOutcome> run(
    String instruction,
    String resource,
    String runId,
  ) async {
    final clean = instruction.trim();
    if (clean.isEmpty || clean.length > 2000)
      throw const FormatException('Usa entre 1 y 2000 caracteres');
    checkActive();
    session.add('user', clean);
    session.pendingInstruction ??= clean;
    final transcript = <Map<String, dynamic>>[];
    final repeated = <String>{};
    var repairs = 0;
    var hasEvidence = false;
    for (var step = 1; step <= maxSteps; step++) {
      checkActive();
      progress('Consultando el modelo · paso $step de $maxSteps');
      final now = DateTime.now();
      final context = <String, dynamic>{
        'protocol': 1,
        'runId': runId,
        'step': step,
        'resource': resource,
        'catalog': tools.catalog,
        'clock': {
          'local': now.toIso8601String(),
          'offsetMinutes': now.timeZoneOffset.inMinutes,
        },
        'pendingInstruction': session.pendingInstruction,
        if (session.pendingQuestion != null)
          'pendingQuestion': session.pendingQuestion,
        'history': session.recent(1600),
        'instruction': clean,
        if (session.evidence.isNotEmpty)
          'previousEvidence': session.evidence.last,
        'tools': assistantToolDefinitions(),
        'transcript': transcript,
      };
      // Evict complete entries, never slice JSON or the pending instruction.
      while (utf8.encode(assistantSystemPrompt + jsonEncode(context)).length >
              8500 &&
          transcript.length > 1) {
        transcript.removeAt(0);
      }
      if (utf8.encode(assistantSystemPrompt + jsonEncode(context)).length >
          9500)
        context.remove('previousEvidence');
      if (utf8.encode(assistantSystemPrompt + jsonEncode(context)).length >
          9500)
        context['history'] = session.recent(600);
      if (utf8.encode(assistantSystemPrompt + jsonEncode(context)).length >
          10000) {
        return _finish(
          'limit',
          'El contexto es demasiado grande. Acota la consulta o inicia una nueva conversacion.',
          step,
        );
      }
      String? raw;
      try {
        raw = await complete(assistantSystemPrompt, jsonEncode(context));
        final reply = AssistantReply.parse(raw);
        checkActive();
        if (reply.kind != 'tool') {
          if (reply.kind == 'answer' && !hasEvidence) {
            throw const FormatException(
              'Antes de responder consulta una herramienta: aggregate_records para contar/calcular, '
              'search_records/get_record para datos, describe_resource para campos. '
              'La ausencia de resultados en el contexto no significa que no haya datos. '
              'Para cambios usa prepare_change; no respondas anunciando que vas a prepararlos. '
              'Si necesitas aclaracion usa kind question.',
            );
          }
          session.pendingQuestion = reply.kind == 'question'
              ? reply.text
              : null;
          if (reply.kind == 'answer') session.pendingInstruction = null;
          return _finish(reply.kind, reply.text, step);
        }
        final signature = jsonEncode(
          _canonical({'name': reply.tool, 'arguments': reply.arguments}),
        );
        if (!repeated.add(signature)) {
          return _finish(
            'limit',
            'El modelo repitio la misma consulta. Revisa los resultados o precisa la solicitud.',
            step,
          );
        }
        progress(switch (reply.tool) {
          'describe_resource' => 'Consultando los campos disponibles…',
          'search_records' => 'Buscando registros locales…',
          'get_record' => 'Leyendo el registro…',
          'aggregate_records' => 'Calculando sobre los datos locales…',
          'prepare_change' => 'Validando el cambio…',
          _ => 'Validando herramienta…',
        });
        final result = await tools.execute(reply.tool!, reply.arguments);
        checkActive();
        final event = {
          'callId': '$runId:$step',
          'name': reply.tool,
          'arguments': reply.arguments,
          ...result,
        };
        transcript.add(event);
        if (result['ok'] == true) {
          hasEvidence = true;
          session.remember(event);
          if (reply.tool == 'prepare_change') {
            session.pendingQuestion = null;
            session.pendingDraft = Map<String, dynamic>.from(result['data']);
            return _finish(
              'draft',
              'Revisa el cambio antes de guardarlo.',
              step,
              draft: Map<String, dynamic>.from(result['data']),
            );
          }
        } else if (++repairs > maxRepairs) {
          return _finish(
            'limit',
            'No pude completar la consulta con datos validos. Revisa la instruccion y los resultados.',
            step,
          );
        }
      } on FormatException catch (error) {
        checkActive();
        if (++repairs > maxRepairs) {
          return _finish(
            'error',
            'El modelo no produjo una respuesta valida. ${error.message}',
            step,
          );
        }
        transcript.add({
          'ok': false,
          'error': {'code': 'invalid_response', 'message': error.message},
          if (raw != null && raw.length <= 2000) 'invalidResponse': raw,
          'instruction':
              'Corrige la respuesta indicada; no la repitas igual. Cierra todos los objetos y listas JSON. Usa el protocolo version 1 o una funcion nativa declarada.',
        });
      }
    }
    return _finish(
      'limit',
      'Se alcanzo el limite de pasos. Puedes precisar la solicitud para continuar; no se guardaron cambios.',
      maxSteps,
    );
  }

  AssistantOutcome _finish(
    String kind,
    String text,
    int steps, {
    Map<String, dynamic>? draft,
  }) {
    checkActive();
    session.add('assistant', text);
    return AssistantOutcome(kind, text, steps, draft: draft);
  }

  Object? _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is List) return value.map(_canonical).toList();
    return value;
  }
}
