import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import '../domain/assistant_prompt.dart';
import '../domain/schema.dart';
import 'model_library.dart';

typedef LocalTranscriber =
    Future<String> Function(TranscribeRequest request, String modelPath);
Future<String> transcribeWhisperFile(
  TranscribeRequest request,
  String modelPath,
) async {
  // Explicit modelPath selects the imported file, including quantized variants.
  final result = await const Whisper(
    model: WhisperModel.base,
  ).transcribe(modelPath: modelPath, transcribeRequest: request);
  return result.text;
}

/// Explicit local path: no initModel or automatic downloads.
class LocalSpeech {
  final ModelLibrary library;
  final AudioRecorder recorder;
  final LocalTranscriber transcribe;
  final Future<Directory> Function() temporaryDirectory;
  LocalSpeech(
    this.library, {
    AudioRecorder? recorder,
    this.transcribe = transcribeWhisperFile,
    this.temporaryDirectory = getTemporaryDirectory,
  }) : recorder = recorder ?? AudioRecorder();
  bool recording = false;
  bool _closed = false;
  String? _audio;
  Timer? _limit;
  Completer<void>? _starting;
  Completer<void>? _transcribing;
  int _generation = 0;
  int lastMilliseconds = 0;
  bool get capturing => recording || _starting != null;
  bool get transcribing => _transcribing != null;
  Future<void> start(void Function() onLimit) async {
    if (_closed || recording || _starting != null || _transcribing != null)
      throw StateError('La grabacion ya esta activa');
    final active = Completer<void>();
    _starting = active;
    final generation = _generation;
    void check() {
      if (_closed || generation != _generation)
        throw StateError('Dictado cancelado');
    }

    try {
      final model = library.speech;
      if (model == null || !await library.file(model).exists()) {
        throw StateError(
          'Importa y selecciona primero un Whisper multilingue .bin',
        );
      }
      check();
      if (!await recorder.hasPermission())
        throw StateError('Se necesita permiso de microfono');
      final directory = await temporaryDirectory();
      check();
      _audio =
          '${directory.path}/dictation-${DateTime.now().microsecondsSinceEpoch}.wav';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _audio!,
      );
      recording = true;
      check();
      _limit = Timer(const Duration(seconds: 45), onLimit);
    } catch (_) {
      await _discard();
      rethrow;
    } finally {
      _starting = null;
      active.complete();
    }
  }

  Future<String> finish(ResourceSpec resource) async {
    _limit?.cancel();
    final path = _audio;
    final model = library.speech;
    if (_closed ||
        _transcribing != null ||
        !recording ||
        path == null ||
        model == null)
      throw StateError('No hay dictado activo');
    final elapsed = Stopwatch()..start();
    final active = Completer<void>();
    _transcribing = active;
    final generation = _generation;
    recording = false;
    var stopped = false;
    try {
      await recorder.stop();
      stopped = true;
      if (_closed || generation != _generation)
        throw StateError('Dictado cancelado');
      if (await File(path).length() <= 3200)
        throw StateError('Grabacion demasiado corta');
      final result = await transcribe(
        TranscribeRequest(
          audio: path,
          language: library.language,
          isTranslate: false,
          isNoTimestamps: true,
          threads: 4,
          noContext: true,
          initialPrompt: transcriptionVocabulary(resource),
          keepModelLoaded: false,
        ),
        library.file(model).path,
      );
      if (_closed || generation != _generation)
        throw StateError('Dictado cancelado');
      final text = result.trim();
      if (text.isEmpty)
        throw StateError('No se reconocio texto. Puedes escribirlo.');
      if (text.length > 2000)
        throw StateError('Dictado demasiado largo; usa frases mas cortas');
      return text;
    } finally {
      recording = false;
      lastMilliseconds = elapsed.elapsedMilliseconds;
      try {
        if (!stopped) await recorder.cancel();
        for (final p in [path, '$path.wav']) {
          final file = File(p);
          if (await file.exists()) await file.delete();
        }
      } finally {
        _audio = null;
        _transcribing = null;
        active.complete();
      }
    }
  }

  Future<void> cancel() async {
    _generation++;
    _limit?.cancel();
    await _starting?.future;
    await _transcribing?.future;
    await _discard();
  }

  Future<void> _discard() async {
    if (recording) {
      await recorder.cancel();
      recording = false;
    }
    if (_audio != null) {
      final file = File(_audio!);
      if (await file.exists()) await file.delete();
      _audio = null;
    }
  }

  Future<void> close() async {
    _closed = true;
    await cancel();
    await recorder.dispose();
  }
}
