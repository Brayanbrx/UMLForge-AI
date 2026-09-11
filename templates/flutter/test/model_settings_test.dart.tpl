import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/model_library.dart';
import '../lib/ui/local_model_settings.dart';

void main() {
  testWidgets('selectores independientes caben en 360px con nombres largos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = ModelLibrary(Directory('unused-widget-models'));
    library.models.addAll([
      const LocalModelFile(
        '11111111-1111-4111-8111-111111111111',
        'gemma-4-E2B-it-modelo-con-nombre-muy-largo.litertlm',
        ModelRuntime.litertlm,
        2500000000,
      ),
      const LocalModelFile(
        '22222222-2222-4222-8222-222222222222',
        'ggml-small-multilingue-cuantizado-q5_1.bin',
        ModelRuntime.whisper,
        180000000,
      ),
    ]);
    library.textId = library.models.first.id;
    library.speechId = library.models.last.id;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LocalModelSettings(
                library: library,
                disabled: false,
                run: (action) => action(),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Modelo de texto'), findsOneWidget);
    expect(find.text('Modelo de voz'), findsOneWidget);
    expect(find.text('Importar LiteRT-LM'), findsOneWidget);
    expect(find.text('Importar Whisper'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('CPU'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
