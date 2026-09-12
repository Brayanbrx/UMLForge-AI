import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/model_library.dart';

class LocalModelSettings extends StatelessWidget {
  final ModelLibrary library;
  final bool disabled;
  final Future<void> Function(Future<void> Function()) run;
  const LocalModelSettings({
    super.key,
    required this.library,
    required this.disabled,
    required this.run,
  });

  Future<void> importModel(ModelRuntime runtime) async {
    final extension = switch (runtime) {
      ModelRuntime.litertlm => 'litertlm',
      ModelRuntime.gguf => 'gguf',
      ModelRuntime.whisper => 'bin',
    };
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [extension],
      withData: false,
    );
    final file = selection?.files.single;
    if (file?.path == null) return;
    final model = await library.importFile(
      File(file!.path!),
      file.name,
      runtime,
    );
    await library.select(model);
  }

  Widget selector(BuildContext context, bool speech) {
    final models = library.models
        .where((m) => (m.runtime == ModelRuntime.whisper) == speech)
        .toList();
    final selected = speech ? library.speech : library.text;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('${speech}_${selected?.id}_${models.length}'),
            initialValue: selected?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: speech ? 'Modelo de voz' : 'Modelo de texto',
            ),
            items: models
                .map(
                  (m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      '${m.name} · ${(m.bytes / 1048576).toStringAsFixed(0)} MB',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: disabled
                ? null
                : (id) => run(() async {
                    if (id != null)
                      await library.select(
                        models.firstWhere((m) => m.id == id),
                      );
                  }),
          ),
        ),
        IconButton(
          tooltip: 'Quitar modelo seleccionado del almacenamiento de la app',
          onPressed: disabled || selected == null
              ? null
              : () => run(() async {
                  final yes = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Quitar modelo'),
                      content: Text(
                        'Se quitara la copia de ${selected.name} de esta app. El archivo original se conserva.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Quitar'),
                        ),
                      ],
                    ),
                  );
                  if (yes == true) await library.remove(selected);
                }),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final runtime in ModelRuntime.values)
            OutlinedButton.icon(
              onPressed: disabled
                  ? null
                  : () => run(() => importModel(runtime)),
              icon: const Icon(Icons.file_open_outlined),
              label: Text(switch (runtime) {
                ModelRuntime.litertlm => 'Importar LiteRT-LM',
                ModelRuntime.gguf => 'Importar GGUF',
                ModelRuntime.whisper => 'Importar Whisper',
              }),
            ),
        ],
      ),
      const SizedBox(height: 12),
      selector(context, false),
      const SizedBox(height: 12),
      selector(context, true),
      const SizedBox(height: 12),
      if (library.text?.runtime == ModelRuntime.litertlm)
        DropdownButtonFormField<String>(
          key: ValueKey('backend-${library.textId}'),
          initialValue: library.backend,
          decoration: const InputDecoration(
            labelText: 'Procesamiento LiteRT-LM',
          ),
          items: const [
            DropdownMenuItem(value: 'cpu', child: Text('CPU')),
            DropdownMenuItem(
              value: 'gpu',
              child: Text('GPU (si el dispositivo y modelo la soportan)'),
            ),
          ],
          isExpanded: true,
          onChanged: disabled
              ? null
              : (v) => run(() async {
                  if (v != null) library.backend = v;
                  await library.save();
                }),
        ),
      if (library.text?.runtime == ModelRuntime.gguf)
        DropdownButtonFormField<String>(
          key: ValueKey('template-${library.textId}'),
          initialValue: library.template,
          decoration: const InputDecoration(
            labelText: 'Plantilla de conversacion GGUF',
          ),
          items: ModelLibrary.templates
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: disabled
              ? null
              : (v) => run(() async {
                  if (v != null) library.template = v;
                  await library.save();
                }),
        ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        key: ValueKey('language-${library.speechId}'),
        initialValue: library.language,
        decoration: const InputDecoration(labelText: 'Idioma de Whisper'),
        items: const [
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'auto', child: Text('Detectar idioma')),
        ],
        onChanged: disabled
            ? null
            : (v) => run(() async {
                if (v != null) library.language = v;
                await library.save();
              }),
      ),
      const SizedBox(height: 8),
      const Text(
        'Whisper: archivo GGML .bin multilingue de whisper.cpp; evita variantes .en para español. '
        'Texto: .litertlm o GGUF de instrucciones. Importar conserva una copia privada; la compatibilidad se comprueba al ejecutar.',
      ),
    ],
  );
}
