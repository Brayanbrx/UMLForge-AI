import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:litertlm/litertlm.dart' as lite;
import '../lib/data/local_agent.dart';
import '../lib/domain/assistant_protocol.dart';

class FakeConversation implements lite.Conversation {
  final List<lite.Message> responses;
  final List<lite.Message> received = [];
  int disposed = 0;
  FakeConversation(this.responses);
  @override
  Future<lite.Message> sendMessage(
    lite.Message message, {
    Map<String, Object?>? extraContext,
    int? maxOutputTokens,
  }) async {
    received.add(message);
    return responses.removeAt(0);
  }

  @override
  Future<int> getTokenCount() async => 50;
  @override
  Future<void> dispose() async {
    disposed++;
  }

  @override
  Future<void> cancel() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNativeEngine implements lite.Engine {
  final FakeConversation conversation;
  lite.ConversationConfig? config;
  int opened = 0;
  FakeNativeEngine(this.conversation);
  @override
  Future<lite.Conversation> createConversation([
    lite.ConversationConfig? conversationConfig,
  ]) async {
    config = conversationConfig;
    opened++;
    return conversation;
  }

  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'JSON tool requests receive user evidence rather than an orphan native tool response',
    () async {
      final conversation = FakeConversation([
        lite.Message.modelText(
          '{"version":1,"kind":"tool","name":"get_record","arguments":{"resource":"clientes","id":1}}',
        ),
        lite.Message.modelText('{"version":1,"kind":"answer","text":"Ana"}'),
      ]);
      final engine = LiteRtTextEngine(
        FakeNativeEngine(conversation),
        nativeTools: true,
      );
      final packet = {
        'protocol': 1,
        'runId': 'json-fallback',
        'tools': assistantToolDefinitions(),
        'transcript': [],
      };
      final first = AssistantReply.parse(
        await engine.generate(assistantSystemPrompt, jsonEncode(packet)).join(),
      );
      expect(first.tool, 'get_record');
      packet['transcript'] = [
        {
          'name': 'get_record',
          'ok': true,
          'data': {'nombre': 'Ana'},
        },
      ];
      await engine.generate(assistantSystemPrompt, jsonEncode(packet)).join();
      expect(conversation.received.last.role, lite.Role.user);
      expect(jsonEncode(conversation.received.last.toJson()), contains('Ana'));
      await engine.close();
    },
  );
  Map<String, dynamic> packet() => {
    'protocol': 1,
    'runId': 'run',
    'tools': assistantToolDefinitions(),
    'instruction': 'consulta',
    'transcript': [],
  };
  test(
    'native call becomes a validated command and receives a tool-role response',
    () async {
      final conversation = FakeConversation([
        lite.Message.model(
          toolCalls: [
            const lite.ToolCall(
              name: 'get_record',
              arguments: {'resource': 'clientes', 'id': 1},
            ),
          ],
        ),
        lite.Message.modelText('{"version":1,"kind":"answer","text":"Ana"}'),
      ]);
      final native = FakeNativeEngine(conversation);
      final engine = LiteRtTextEngine(native, nativeTools: true);
      final request = packet();
      final call = AssistantReply.parse(
        await engine
            .generate(assistantSystemPrompt, jsonEncode(request))
            .join(),
      );
      expect(call.tool, 'get_record');
      expect(native.config!.automaticToolCalling, false);
      expect(native.config!.tools, hasLength(6));
      request['transcript'] = [
        {
          'name': 'get_record',
          'ok': true,
          'data': {'id': 1, 'nombre': 'Ana'},
        },
      ];
      final answer = AssistantReply.parse(
        await engine
            .generate(assistantSystemPrompt, jsonEncode(request))
            .join(),
      );
      expect(answer.text, 'Ana');
      expect(native.opened, 1);
      expect(conversation.received.last.role, lite.Role.tool);
      expect(jsonEncode(conversation.received.last.toJson()), contains('Ana'));
      await expectLater(
        Future.sync(() => native.config!.tools.first.execute({})),
        throwsStateError,
      );
      await engine.close();
      expect(conversation.disposed, 1);
    },
  );
  test(
    'native compatibility probe rejects JSON imitation without a native call',
    () async {
      final conversation = FakeConversation([
        lite.Message.modelText(
          '{"version":1,"kind":"tool","name":"describe_resource","arguments":{"resource":"prueba"}}',
        ),
      ]);
      final engine = LiteRtTextEngine(
        FakeNativeEngine(conversation),
        nativeTools: true,
      );
      await expectLater(
        engine
            .generate(
              assistantSystemPrompt,
              jsonEncode({...packet(), 'requireNativeCall': true}),
            )
            .join(),
        throwsFormatException,
      );
      await engine.close();
    },
  );
  test('native terminal tool preserves question versus answer', () async {
    final conversation = FakeConversation([
      lite.Message.model(
        toolCalls: [
          const lite.ToolCall(
            name: 'respond_to_user',
            arguments: {'kind': 'question', 'text': 'Ana Perez o Ana Lopez?'},
          ),
        ],
      ),
    ]);
    final engine = LiteRtTextEngine(
      FakeNativeEngine(conversation),
      nativeTools: true,
    );
    final reply = AssistantReply.parse(
      await engine.generate(assistantSystemPrompt, jsonEncode(packet())).join(),
    );
    expect(reply.kind, 'question');
    expect(reply.text, contains('Ana Lopez'));
    await engine.close();
  });
  test(
    'multiple native calls are rejected before executing any tool',
    () async {
      final conversation = FakeConversation([
        lite.Message.model(
          toolCalls: [
            const lite.ToolCall(
              name: 'get_record',
              arguments: {'resource': 'clientes', 'id': 1},
            ),
            const lite.ToolCall(
              name: 'prepare_change',
              arguments: {'resource': 'clientes', 'action': 'DELETE', 'id': 1},
            ),
          ],
        ),
      ]);
      final engine = LiteRtTextEngine(
        FakeNativeEngine(conversation),
        nativeTools: true,
      );
      await expectLater(
        engine.generate(assistantSystemPrompt, jsonEncode(packet())).join(),
        throwsFormatException,
      );
      await engine.close();
    },
  );
}
