import 'dart:async';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:litertlm/litertlm.dart' as lite;
import '../domain/assistant_prompt.dart';
import '../domain/schema.dart';
import '../domain/proposal.dart';
import 'model_library.dart';

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

abstract class LocalTextEngine {
  Stream<String> generate(String system, String context);
  Future<void> stop();
  Future<void> close();
}

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
  lite.Conversation? conversation;
  LiteRtTextEngine(this.engine);
  static Future<LiteRtTextEngine> open(
    String path,
    String backend,
    String cache,
  ) async {
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
      return LiteRtTextEngine(engine);
    } catch (_) {
      await engine.dispose();
      rethrow;
    }
  }

  @override
  Stream<String> generate(String system, String context) async* {
    final current = await engine.createConversation(
      lite.ConversationConfig(
        systemMessage: lite.Message.system(system),
        automaticToolCalling: false,
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

  @override
  Future<void> stop() async {
    await conversation?.cancel();
  }

  @override
  Future<void> close() => engine.dispose();
}

typedef TextEngineFactory =
    Future<LocalTextEngine> Function(
      ModelLibrary library,
      LocalModelFile model,
    );
Future<LocalTextEngine> openLocalTextEngine(
  ModelLibrary library,
  LocalModelFile model,
) async {
  final path = library.file(model).path;
  if (model.runtime == ModelRuntime.litertlm) {
    return LiteRtTextEngine.open(path, library.backend, library.directory.path);
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
  bool _cancelled = false, _closed = false;
  int lastMilliseconds = 0;
  LocalAgent(this.library, {this.factory = openLocalTextEngine});
  bool get loaded => library.text != null;
  bool get processing => _active != null;

  @override
  Future<Proposal> propose(
    String instruction,
    AppSchema schema,
    ResourceSpec resource,
    List<Map<String, dynamic>> rows,
  ) async {
    if (_closed || _active != null)
      throw StateError('Espera a que termine la solicitud');
    final model = library.text;
    if (model == null) throw StateError('Selecciona un modelo de texto local');
    final context = managementContext(instruction, resource, rows);
    final active = Completer<void>();
    _active = active;
    _cancelled = false;
    final elapsed = Stopwatch()..start();
    Timer? deadline;
    try {
      // Release after each request so Whisper and the LLM do not occupy RAM together.
      _engine = await factory(library, model);
      if (_cancelled || _closed) throw StateError('Solicitud cancelada');
      deadline = Timer(const Duration(seconds: 120), () {
        unawaited(stop());
      });
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
      final proposal = Proposal.parse(result.toString(), schema);
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
      deadline?.cancel();
      try {
        await _engine?.stop();
      } finally {
        try {
          await _engine?.close();
        } finally {
          _engine = null;
          lastMilliseconds = elapsed.elapsedMilliseconds;
          _active = null;
          active.complete();
        }
      }
    }
  }

  @override
  Future<void> stop() async {
    _cancelled = true;
    await _engine?.stop();
  }

  @override
  Future<void> close() async {
    _closed = true;
    await stop();
    await _active?.future;
  }
}
