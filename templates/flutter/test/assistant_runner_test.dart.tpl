import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/assistant_tools.dart';
import '../lib/data/repository.dart';
import '../lib/domain/assistant_runner.dart';
import '../lib/domain/assistant_session.dart';
import 'support/assistant_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Repository repository;
  late AssistantSession session;
  setUp(() async {
    repository = await assistantRepository();
    session = AssistantSession();
  });
  tearDown(() async {
    await repository.local.close();
  });

  AssistantRunner runner(
    ScriptedEngine engine, {
    int maxSteps = 8,
    void Function()? check,
  }) => AssistantRunner(
    complete: (system, context) => engine.generate(system, context).join(),
    tools: LocalAssistantTools(repository, check ?? () {}),
    session: session,
    checkActive: check ?? () {},
    progress: (_) {},
    maxSteps: maxSteps,
  );
  test(
    'search then clarification then short reply then read and draft',
    () async {
      final first = ScriptedEngine([
        toolReply('search_records', {
          'resource': 'clientes',
          'filters': [
            {'field': 'nombre', 'op': 'contains', 'value': 'Ana'},
          ],
        }),
        answerReply('¿Ana Perez o Ana Lopez?', 'question'),
      ]);
      final question = await runner(
        first,
      ).run('Cambia el telefono de Ana a 77712345', 'clientes', 'run1');
      expect(question.kind, 'question');
      expect(question.steps, 2);
      final second = ScriptedEngine([
        toolReply('get_record', {'resource': 'clientes', 'id': 1}),
        toolReply('prepare_change', {
          'resource': 'clientes',
          'action': 'UPDATE',
          'id': 1,
          'data': {'telefono': '77712345'},
        }),
      ]);
      final draft = await runner(second).run('Perez', 'clientes', 'run2');
      expect(draft.kind, 'draft');
      expect(second.contexts.first['pendingInstruction'], contains('77712345'));
      expect(second.contexts.first['pendingQuestion'], contains('Lopez'));
      expect(
        second.contexts.first['previousEvidence']['data']['records'],
        hasLength(2),
      );
      expect(session.pendingDraft!['proposal']['id'], 1);
      expect(await repository.local.queue(), isEmpty);
    },
  );
  test(
    'invalid output is corrected with concrete feedback and bounded repairs',
    () async {
      final engine = ScriptedEngine([
        'no json',
        answerReply('¿Que nombre?', 'question'),
      ]);
      expect(
        (await runner(engine).run('crear', 'clientes', 'repair')).kind,
        'question',
      );
      expect(
        jsonEncode(engine.contexts.last['transcript']),
        contains('invalid_response'),
      );
      final broken = ScriptedEngine(['x', 'x', 'x', 'unused']);
      expect(
        (await runner(broken).run('crear', 'clientes', 'broken')).kind,
        'error',
      );
      expect(broken.contexts, hasLength(3));
    },
  );
  test('repeated equivalent call stops and no write is possible', () async {
    final engine = ScriptedEngine([
      toolReply('get_record', {'resource': 'clientes', 'id': 1}),
      toolReply('get_record', {'id': 1, 'resource': 'clientes'}),
    ]);
    expect(
      (await runner(engine).run('consulta', 'clientes', 'repeat')).kind,
      'limit',
    );
    expect(session.evidence, hasLength(1));
    expect(await repository.local.queue(), isEmpty);
  });
  test('ungrounded answer is repaired using real tool evidence', () async {
    final engine = ScriptedEngine([
      answerReply('No hay informacion sobre cuantos clientes hay.'),
      toolReply('aggregate_records', {
        'resource': 'clientes',
        'operation': 'count',
      }),
      answerReply('Hay 3 clientes.'),
    ]);
    final result = await runner(
      engine,
    ).run('Cuantos clientes hay?', 'clientes', 'grounded');
    expect(result.kind, 'answer');
    expect(result.text, 'Hay 3 clientes.');
    expect(result.steps, 3);
    expect(
      jsonEncode(engine.contexts[1]['transcript']),
      contains('Antes de responder'),
    );
    expect(
      session.messages.any(
        (message) => message['text'].toString().contains('No hay informacion'),
      ),
      isFalse,
    );
    expect(await repository.local.queue(), isEmpty);
  });
  test('budget ends even if every request differs', () async {
    final engine = ScriptedEngine([
      for (var id = 1; id <= 3; id++)
        toolReply('get_record', {'resource': 'clientes', 'id': id}),
    ]);
    final result = await runner(
      engine,
      maxSteps: 2,
    ).run('consulta', 'clientes', 'limit');
    expect(result.kind, 'limit');
    expect(result.steps, 2);
    expect(engine.responses, hasLength(1));
  });
  test(
    'session invalidation prevents late model output and tool calls',
    () async {
      final epoch = session.generation;
      var called = 0;
      final task = AssistantRunner(
        complete: (_, _) async {
          session.clear();
          return toolReply('prepare_change', {
            'resource': 'clientes',
            'action': 'CREATE',
            'data': {'id': 8, 'nombre': 'Invalido'},
          });
        },
        tools: LocalAssistantTools(repository, () {
          called++;
        }),
        session: session,
        checkActive: () {
          if (epoch != session.generation) throw StateError('sesion');
        },
        progress: (_) {},
      );
      await expectLater(
        task.run('crea', 'clientes', 'cancel'),
        throwsStateError,
      );
      expect(called, 0);
      expect(session.messages, isEmpty);
      expect(session.pendingDraft, isNull);
    },
  );
}
