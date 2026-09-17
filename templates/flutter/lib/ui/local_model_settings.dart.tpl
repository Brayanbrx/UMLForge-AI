import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/model_library.dart';
import '../data/remote_ai.dart';

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

  Widget modeSelector(bool speech) => DropdownButtonFormField<String>(
    key: ValueKey(
      'mode-${speech ? 'speech' : 'text'}-${speech ? library.speechMode : library.textMode}',
    ),
    initialValue: speech ? library.speechMode : library.textMode,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: speech ? 'Origen de la voz' : 'Origen del texto',
    ),
    items: [
      DropdownMenuItem(
        value: 'local',
        child: Text(
          speech
              ? 'Whisper local (modelo importado, sin internet)'
              : 'Modelo local importado (sin internet)',
        ),
      ),
      DropdownMenuItem(
        value: 'remote',
        child: Text(
          'IA en linea (${speech ? library.remote.speechLabel : library.remote.textLabel})',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
    onChanged: disabled
        ? null
        : (v) => run(() async {
            if (v == null) return;
            if (speech) {
              library.speechMode = v;
            } else {
              library.textMode = v;
            }
            await library.save();
          }),
  );

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
      modeSelector(false),
      const SizedBox(height: 12),
      modeSelector(true),
      const SizedBox(height: 12),
      if (library.textRemote || library.speechRemote) ...[
        RemoteAiForm(library: library, disabled: disabled, run: run),
        const SizedBox(height: 12),
      ],
      if (!library.textRemote || !library.speechRemote) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final runtime in ModelRuntime.values)
              if ((runtime == ModelRuntime.whisper)
                  ? !library.speechRemote
                  : !library.textRemote)
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
      ],
      if (!library.textRemote) ...[
        selector(context, false),
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
      ],
      if (!library.speechRemote) ...[
        selector(context, true),
        const SizedBox(height: 12),
      ],
      DropdownButtonFormField<String>(
        key: ValueKey('language-${library.speechId}'),
        initialValue: library.language,
        decoration: const InputDecoration(labelText: 'Idioma del dictado'),
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
      Text(
        library.textRemote || library.speechRemote
            ? 'IA en linea: la instruccion o el audio viajan al proveedor elegido con tu clave; la app sigue validando cada propuesta y pidiendo confirmacion. Sin internet usa los modelos locales.'
            : 'Whisper: archivo GGML .bin multilingue de whisper.cpp; evita variantes .en para español. '
                  'Texto: .litertlm o GGUF de instrucciones. Importar conserva una copia privada; la compatibilidad se comprueba al ejecutar.',
      ),
    ],
  );
}

/// Proveedor, modelo y clave de la IA en linea, con los mismos nombres que
/// `infra/.env`: lo que se pega aqui es lo mismo que se pegaria en `ai.env`.
class RemoteAiForm extends StatefulWidget {
  final ModelLibrary library;
  final bool disabled;
  final Future<void> Function(Future<void> Function()) run;
  const RemoteAiForm({
    super.key,
    required this.library,
    required this.disabled,
    required this.run,
  });
  @override
  State<RemoteAiForm> createState() => _RemoteAiFormState();
}

class _RemoteAiFormState extends State<RemoteAiForm> {
  late final TextEditingController textModel, speechModel, textKey, speechKey;
  late String textProvider, speechProvider;
  RemoteAiSettings get remote => widget.library.remote;

  @override
  void initState() {
    super.initState();
    textProvider = remote.textSpec?.id ?? AiProvider.forText.first.id;
    speechProvider = remote.speechSpec?.id ?? AiProvider.forSpeech.first.id;
    textModel = TextEditingController(text: remote.textModel);
    speechModel = TextEditingController(text: remote.speechModel);
    textKey = TextEditingController(
      text: remote.keyFor(AiProvider.byId(textProvider)!),
    );
    speechKey = TextEditingController(
      text: remote.keyFor(AiProvider.byId(speechProvider)!),
    );
  }

  @override
  void dispose() {
    for (final c in [textModel, speechModel, textKey, speechKey]) c.dispose();
    super.dispose();
  }

  Widget providerField({
    required bool speech,
    required String value,
    required List<AiProvider> providers,
    required void Function(String) onChanged,
  }) => DropdownButtonFormField<String>(
    key: ValueKey('provider-${speech ? 'speech' : 'text'}-$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: speech
          ? 'Proveedor de voz (AI_SPEECH_PROVIDER)'
          : 'Proveedor de texto (AI_LLM_PROVIDER)',
    ),
    items: providers
        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.id)))
        .toList(),
    onChanged: widget.disabled
        ? null
        : (v) {
            if (v != null) setState(() => onChanged(v));
          },
  );

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    final textSpec = AiProvider.byId(textProvider)!;
    final speechSpec = AiProvider.byId(speechProvider)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('IA en linea', style: Theme.of(context).textTheme.titleMedium),
            const Text(
              'Mismos nombres que infra/.env del generador. Las claves se guardan en el almacenamiento seguro de este telefono.',
            ),
            if (library.textRemote) ...[
              const SizedBox(height: 12),
              providerField(
                speech: false,
                value: textProvider,
                providers: AiProvider.forText,
                onChanged: (v) {
                  textProvider = v;
                  final spec = AiProvider.byId(v)!;
                  if (textModel.text.trim().isEmpty ||
                      AiProvider.all.any(
                        (p) => p.defaultModel == textModel.text.trim(),
                      ))
                    textModel.text = spec.defaultModel;
                  textKey.text = remote.keyFor(spec);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textModel,
                enabled: !widget.disabled,
                decoration: const InputDecoration(
                  labelText: 'Modelo de texto (AI_LLM_MODEL)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textKey,
                enabled: !widget.disabled,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Clave (${textSpec.keyName})',
                ),
              ),
            ],
            if (library.speechRemote) ...[
              const SizedBox(height: 12),
              providerField(
                speech: true,
                value: speechProvider,
                providers: AiProvider.forSpeech,
                onChanged: (v) {
                  speechProvider = v;
                  final spec = AiProvider.byId(v)!;
                  if (speechModel.text.trim().isEmpty ||
                      AiProvider.speechModels.values.contains(
                        speechModel.text.trim(),
                      ))
                    speechModel.text = spec.defaultSpeechModel;
                  speechKey.text = remote.keyFor(spec);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: speechModel,
                enabled: !widget.disabled,
                decoration: const InputDecoration(
                  labelText: 'Modelo de voz (AI_SPEECH_MODEL)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: speechKey,
                enabled: !widget.disabled,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Clave (${speechSpec.keyName})',
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.disabled
                  ? null
                  : () => widget.run(() async {
                      if (library.textRemote) {
                        remote
                          ..set('AI_LLM_PROVIDER', textProvider)
                          ..set('AI_LLM_MODEL', textModel.text)
                          ..set(textSpec.keyName, textKey.text);
                      }
                      if (library.speechRemote) {
                        remote
                          ..set('AI_SPEECH_PROVIDER', speechProvider)
                          ..set('AI_SPEECH_MODEL', speechModel.text)
                          ..set(speechSpec.keyName, speechKey.text);
                      }
                      await remote.save();
                      await library.save();
                    }),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar IA en linea en este telefono'),
            ),
          ],
        ),
      ),
    );
  }
}
