import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/local_agent.dart';
import '../lib/data/model_library.dart';
import '../lib/domain/schema.dart';
import '../lib/domain/assistant_prompt.dart';

class FakeEngine implements LocalTextEngine {
  String output;
  String? system, context;
  bool closed = false;
  FakeEngine(this.output);
  @override
  Stream<String> generate(String s, String c) async* {
    system = s;
    context = c;
    yield output;
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> close() async {
    closed = true;
  }
}

void main() {
  final schema = AppSchema({
    'project': 'test',
    'resources': [
      {
        'className': 'Cliente',
        'path': '/api/clientes',
        'primaryKey': 'id',
        'fields': [
          {
            'name': 'id',
            'javaType': 'UUID',
            'primaryKey': true,
            'nullable': false,
          },
          {'name': 'nombre', 'javaType': 'String', 'nullable': false},
        ],
      },
    ],
  });
  final library = ModelLibrary(Directory('unused-test-models'));
  library.models.add(
    const LocalModelFile(
      '11111111-1111-4111-8111-111111111111',
      'test',
      ModelRuntime.litertlm,
      100,
    ),
  );
  library.textId = library.models.first.id;
  final resource = schema.resources.first;

  test(
    'aplica prompt comun y valida CREATE sin ejecutar llamadas ni persistir datos',
    () async {
      final engine = FakeEngine(
        '{"action":"CREATE","resource":"clientes","data":{"nombre":"Ana"}}',
      );
      final agent = LocalAgent(library, factory: (_, _) async => engine);
      final proposal = await agent.propose('Crea a Ana', schema, resource, []);
      expect(proposal.data!['nombre'], 'Ana');
      expect(proposal.data!['id'], isNotEmpty);
      expect(engine.system, managementSystemPrompt);
      expect(jsonDecode(engine.context!)['instruction'], 'Crea a Ana');
      expect(engine.closed, isTrue);
    },
  );
  test(
    'rechaza campo inventado y libera el motor aunque falle la validacion',
    () async {
      final engine = FakeEngine(
        '{"action":"CREATE","resource":"clientes","data":{"nombre":"Ana","admin":true}}',
      );
      final agent = LocalAgent(library, factory: (_, _) async => engine);
      await expectLater(
        agent.propose('Crea Ana', schema, resource, []),
        throwsFormatException,
      );
      expect(engine.closed, isTrue);
    },
  );
  test(
    'rechaza DELETE de clave ausente y pregunta sin generar cambios',
    () async {
      for (final output in [
        '{"action":"DELETE","resource":"clientes","id":"inventado"}',
        '{"question":"¿Cual cliente?"}',
      ]) {
        final engine = FakeEngine(output);
        final agent = LocalAgent(library, factory: (_, _) async => engine);
        await expectLater(
          agent.propose('Borra Ana', schema, resource, []),
          throwsFormatException,
        );
        expect(engine.closed, isTrue);
      }
    },
  );
  test('cancelar durante carga descarta resultado y libera el motor', () async {
    final load = Completer<LocalTextEngine>();
    final engine = FakeEngine('{"action":"LIST","resource":"clientes"}');
    final agent = LocalAgent(library, factory: (_, _) => load.future);
    final pending = agent.propose('lista', schema, resource, []);
    final check = expectLater(pending, throwsStateError);
    await agent.stop();
    load.complete(engine);
    await check;
    expect(engine.closed, isTrue);
  });
  test(
    'vocabulario de voz acotado sin registros ni instrucciones del usuario',
    () {
      expect(transcriptionVocabulary(resource), 'Cliente, id, nombre');
      expect(
        () => managementContext('a' * 2001, resource, []),
        throwsFormatException,
      );
    },
  );
}
