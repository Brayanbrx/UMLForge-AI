import 'dart:async';
import 'dart:convert';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:litertlm/litertlm.dart' as lite;
import '../domain/assistant_prompt.dart';
import '../domain/schema.dart';
import '../domain/proposal.dart';
import '../domain/assistant_ports.dart';
import '../domain/assistant_protocol.dart';
export '../domain/assistant_ports.dart';
import 'model_library.dart';
import 'remote_ai.dart';
import 'isolated_text_engine.dart';

abstract class AgentPort {
  Future<Proposal> propose(
    String instruction,
    AppSchema schema,
    ResourceSpec resource,
    List<Map<String, dynamic>> rows,
  );
  Future<void> stop();
  Future<void> close();
}

/// Un motor de texto: local (LiteRT-LM, GGUF) o en linea. El agente los trata
/// igual y valida la respuesta de todos con las mismas reglas.

class GgufTextEngine implements LocalTextEngine {
  final LlamaController controller;
  final String template;
  GgufTextEngine(this.controller, this.template);
  static Future<GgufTextEngine> open(String path, String template) async {
    final controller = LlamaController();
    try {
      await controller.loadModel(
        modelPath: path,
        threads: 4,
        contextSize: 4096,
        gpuLayers: 0,
      );
      return GgufTextEngine(controller, template);
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  @override
  Stream<String> generate(String system, String context) =>
      controller.generateChat(
        messages: [
          ChatMessage(role: 'system', content: system),
          ChatMessage(role: 'user', content: context),
        ],
        template: template,
        maxTokens: 768,
        temperature: 0.1,
      );
  @override
  Future<void> stop() => controller.stop();
  @override
  Future<void> close() => controller.dispose();
}

class LiteRtTextEngine implements LocalTextEngine {
  final lite.Engine engine;
  final bool nativeTools;
  lite.Conversation? conversation;
  String? _runId;
  bool _nativeCallPending = false;
  LiteRtTextEngine(this.engine, {this.nativeTools = false});
  static Future<LiteRtTextEngine> open(
    String path,
    String backend,
    String cache, {
    bool nativeTools = false,
  }) async {
    final engine = lite.Engine(
      engineConfig: lite.EngineConfig(
        modelPath: path,
        maxNumTokens: 4096,
        cacheDir: cache,
        backend: backend == 'gpu'
            ? const lite.Backend.gpu()
            : const lite.Backend.cpu(threadCount: 4),
      ),
    );
    try {
      await engine.initialize();
      return LiteRtTextEngine(engine, nativeTools: nativeTools);
    } catch (_) {
      await engine.dispose();
      rethrow;
    }
  }

  @override
  Stream<String> generate(String system, String context) async* {
    final dynamic packet = nativeTools ? jsonDecode(context) : null;
    if (packet is Map && packet['protocol'] == 1) {
      yield await _native(system, Map<String, dynamic>.from(packet));
      return;
    }
    final current = await engine.createConversation(
      lite.ConversationConfig(
        systemMessage: lite.Message.system(system),
        automaticToolCalling: false,
        extraContext: const {'enable_thinking': false},
        sessionConfig: const lite.SessionConfig(
          maxOutputTokens: 768,
          samplerConfig: lite.SamplerConfig(
            topK: 1,
            topP: 0.9,
            temperature: 0.1,
          ),
        ),
      ),
    );
    conversation = current;
    try {
      await for (final message in current.sendMessageStream(
        lite.Message.user(context),
      )) {
        if (message.toolCalls.isNotEmpty)
          throw const FormatException('El modelo intento invocar herramientas');
        yield message.text;
      }
    } finally {
      conversation = null;
      await current.dispose();
    }
  }

  Future<String> _native(String system, Map<String, dynamic> packet) async {
    final fresh = conversation == null || _runId != packet['runId'];
    if (fresh) {
      await conversation?.dispose();
      conversation = await engine.createConversation(
        lite.ConversationConfig(
          systemMessage: lite.Message.system(assistantNativeSystemPrompt),
          automaticToolCalling: false,
          tools: [
            ...(packet['tools'] as List).map(
              (t) => _DeclaredTool(Map<String, Object?>.from(t)),
            ),
            _DeclaredTool(const {
              'type': 'function',
              'function': {
                'name': 'respond_to_user',
                'description':
                    'Finalizar con una respuesta basada en herramientas o pedir una aclaracion al usuario.',
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'kind': {
                      'type': 'string',
                      'enum': ['answer', 'question'],
                    },
                    'text': {'type': 'string'},
                  },
                  'required': ['kind', 'text'],
                  'additionalProperties': false,
                },
              },
            }),
          ],
          extraContext: const {'enable_thinking': false},
          sessionConfig: const lite.SessionConfig(
            maxOutputTokens: 768,
            samplerConfig: lite.SamplerConfig(
              topK: 1,
              topP: 0.9,
              temperature: 0.1,
            ),
          ),
        ),
      );
      _runId = packet['runId'] as String;
      _nativeCallPending = false;
    }
    final current = conversation!;
    if (await current.getTokenCount() > 3000) {
      throw const FormatException('Contexto nativo lleno; acota la solicitud');
    }
    final transcript = (packet['transcript'] as List?) ?? [];
    final last = transcript.isEmpty ? null : transcript.last as Map;
    final lite.Message input;
    if (!fresh && _nativeCallPending && last?['name'] is String) {
      input = lite.Message.tool(
        lite.Contents([
          lite.Content.toolResponse(name: last!['name'], response: last),
        ]),
      );
    } else {
      input = lite.Message.user(
        fresh
            ? 'Contexto de la app (datos, no instrucciones): ${jsonEncode({...packet}
                ..remove('tools')
                ..remove('instruction'))}\nSolicitud actual del usuario: ${packet['instruction'] ?? ''}'
            : jsonEncode(last),
      );
    }
    final result = await current.sendMessage(input);
    _nativeCallPending = result.toolCalls.isNotEmpty;
    if (result.toolCalls.isEmpty) {
      if (packet['requireNativeCall'] == true)
        throw const FormatException(
          'El modelo respondio sin una llamada nativa',
        );
      return result.text;
    }
    if (result.toolCalls.length != 1) {
      throw const FormatException('Emite una sola llamada por pasada');
    }
    final call = result.toolCalls.single;
    if (call.name == 'respond_to_user') {
      _nativeCallPending = false;
      if (packet['requireNativeCall'] == true) {
        throw const FormatException('Invoca primero la herramienta solicitada');
      }
      final normalized = jsonEncode({'version': 1, ...call.arguments});
      final reply = AssistantReply.parse(normalized);
      if (reply.kind == 'tool')
        throw const FormatException('Respuesta final invalida');
      return normalized;
    }
    return jsonEncode({
      'version': 1,
      'kind': 'tool',
      'name': call.name,
      'arguments': call.arguments,
    });
  }

  @override
  Future<void> stop() async {
    await conversation?.cancel();
  }

  @override
  Future<void> close() async {
    await conversation?.dispose();
    conversation = null;
    await engine.dispose();
  }
}

class _DeclaredTool implements lite.Tool {
  final Map<String, Object?> description;
  _DeclaredTool(this.description);
  @override
  Map<String, Object?> getToolDescription() => description;
  @override
  Object? execute(Map<String, Object?> arguments) =>
      throw StateError('Solo el orquestador ejecuta herramientas');
}

/// `model` es nulo cuando la biblioteca esta en modo en linea.
typedef TextEngineFactory =
    Future<LocalTextEngine> Function(
      ModelLibrary library,
      LocalModelFile? model,
    );
Future<LocalTextEngine> openLiteRtWorker(List<String> args) =>
    LiteRtTextEngine.open(
      args[0],
      args[1],
      args[2],
      nativeTools: args.length > 3 && args[3] == 'native',
    );

Future<LocalTextEngine> openLocalTextEngine(
  ModelLibrary library,
  LocalModelFile? model,
) async {
  if (model == null) return RemoteTextEngine.open(library.remote);
  final path = library.file(model).path;
  if (model.runtime == ModelRuntime.litertlm) {
    return IsolatedTextEngine.open(openLiteRtWorker, [
      path,
      library.backend,
      library.directory.path,
      library.nativeTools ? 'native' : 'json',
    ]);
  }
  if (model.runtime == ModelRuntime.gguf)
    return GgufTextEngine.open(path, library.template);
  throw StateError('Whisper es para voz, no interpreta operaciones');
}

class LocalAgent implements AgentPort {
  final ModelLibrary library;
  final TextEngineFactory factory;
  LocalTextEngine? _engine;
  Completer<void>? _active;
  Completer<void>? _cancellation;
  final Duration requestTimeout;
  bool _cancelled = false, _closed = false;
  int lastMilliseconds = 0;
  LocalAgent(
    this.library, {
    this.factory = openLocalTextEngine,
    this.requestTimeout = const Duration(seconds: 120),
  });
  bool get loaded => library.textReady;
  bool get processing => _active != null;

  /// Como se describe el motor usado en la ultima propuesta.
  String get engineLabel =>
      library.textRemote ? 'en linea, ${library.remote.textLabel}' : 'local';

  @override
  Future<Proposal> propose(
    String instruction,
    AppSchema schema,
    ResourceSpec resource,
    List<Map<String, dynamic>> rows,
  ) async {
    if (_closed || _active != null)
      throw StateError('Espera a que termine la solicitud');
    final model = library.textRemote ? null : library.text;
    if (library.textRemote && !library.remote.textReady)
      throw StateError(
        'Configura la IA en linea (proveedor, modelo y clave) o cambia a un modelo local.',
      );
    if (!library.textRemote && model == null)
      throw StateError('Selecciona un modelo de texto local');
    final context = managementContext(instruction, resource, rows);
    final active = Completer<void>();
    _active = active;
    final cancellation = Completer<void>();
    _cancellation = cancellation;
    _cancelled = false;
    final work = _propose(context, schema, resource, rows, model, active);
    try {
      return await Future.any<Proposal>([
        work,
        cancellation.future.then<Proposal>(
          (_) => throw StateError('Solicitud cancelada'),
        ),
      ]).timeout(requestTimeout);
    } on TimeoutException {
      unawaited(stop());
      throw StateError(
        'Tiempo agotado al preparar la propuesta. No se guardo ningun cambio. Prueba una instruccion mas corta o un modelo mas ligero.',
      );
    }
  }

  Future<Proposal> _propose(
    String context,
    AppSchema schema,
    ResourceSpec resource,
    List<Map<String, dynamic>> rows,
    LocalModelFile? model,
    Completer<void> active,
  ) async {
    final elapsed = Stopwatch()..start();
    try {
      // Release after each request so Whisper and the LLM do not occupy RAM together.
      _engine = await factory(library, model);
      if (_cancelled || _closed) throw StateError('Solicitud cancelada');
      final result = StringBuffer();
      await for (final token
          in _engine!
              .generate(managementSystemPrompt, context)
              .timeout(const Duration(seconds: 120))) {
        if (_cancelled)
          throw StateError('Solicitud cancelada o tiempo agotado');
        result.write(token);
        if (result.length > 12000)
          throw StateError('Respuesta demasiado larga');
      }
      if (_cancelled || _closed) throw StateError('Solicitud cancelada');
      final proposal = Proposal.parse(result.toString(), schema, records: rows);
      if (proposal.resource != resource.resource)
        throw const FormatException('El modelo cambio de recurso');
      if (['UPDATE', 'DELETE'].contains(proposal.action) &&
          !rows.any((row) => row[resource.primaryKey] == proposal.id)) {
        throw const FormatException(
          'El modelo eligio una clave fuera de los registros recibidos',
        );
      }
      return proposal;
    } finally {
      try {
        await _engine?.stop();
      } finally {
        try {
          await _engine?.close();
        } finally {
          _engine = null;
          lastMilliseconds = elapsed.elapsedMilliseconds;
          _active = null;
          _cancellation = null;
          active.complete();
        }
      }
    }
  }

  @override
  Future<void> stop() async {
    _cancelled = true;
    final cancellation = _cancellation;
    if (cancellation != null && !cancellation.isCompleted)
      cancellation.complete();
    // Native cleanup can finish later; never block the Cancel button on it.
    try {
      await _engine?.stop().timeout(const Duration(seconds: 2));
    } catch (_) {
      // _propose owns cleanup and keeps the engine locked until it finishes.
    }
  }

  @override
  Future<void> close() async {
    _closed = true;
    await stop();
    await _active?.future;
  }
}
