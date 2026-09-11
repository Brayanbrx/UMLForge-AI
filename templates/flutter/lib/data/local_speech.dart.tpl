import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import '../domain/assistant_prompt.dart';
import '../domain/schema.dart';
import 'model_library.dart';

/// Explicit local path: no initModel or automatic downloads.
class LocalSpeech {
  final ModelLibrary library;
  final AudioRecorder recorder = AudioRecorder();
  LocalSpeech(this.library);
  bool recording = false;
  bool _closed = false;
  String? _audio;
  Timer? _limit;
  Completer<void>? _transcribing;
  int lastMilliseconds = 0;
  Future<void> start(void Function() onLimit) async {
    if (_closed || recording) throw StateError('La grabacion ya esta activa');
    final model = library.speech;
    if (model == null || !await library.file(model).exists()) {
      throw StateError(
        'Importa y selecciona primero un Whisper multilingue .bin',
      );
    }
    if (!await recorder.hasPermission())
      throw StateError('Se necesita permiso de microfono');
    final directory = await getTemporaryDirectory();
    _audio =
        '${directory.path}/dictation-${DateTime.now().microsecondsSinceEpoch}.wav';
    try {
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _audio!,
      );
      recording = true;
      _limit = Timer(const Duration(seconds: 45), onLimit);
    } catch (_) {
      await cancel();
      rethrow;
    }
  }

  Future<String> finish(ResourceSpec resource) async {
    _limit?.cancel();
    final path = _audio;
    final model = library.speech;
    if (!recording || path == null || model == null)
      throw StateError('No hay dictado activo');
    final elapsed = Stopwatch()..start();
    final active = Completer<void>();
    _transcribing = active;
    try {
      await recorder.stop();
      recording = false;
      if (await File(path).length() <= 3200)
        throw StateError('Grabacion demasiado corta');
      // Explicit modelPath chooses the imported weights; the enum does not download anything.
      final result = await const Whisper(model: WhisperModel.base).transcribe(
        modelPath: library.file(model).path,
        transcribeRequest: TranscribeRequest(
          audio: path,
          language: library.language,
          isTranslate: false,
          isNoTimestamps: true,
          threads: 4,
          noContext: true,
          initialPrompt: transcriptionVocabulary(resource),
          keepModelLoaded: false,
        ),
      );
      if (_closed) throw StateError('Dictado cancelado');
      final text = result.text.trim();
      if (text.isEmpty)
        throw StateError('No se reconocio texto. Puedes escribirlo.');
      if (text.length > 2000)
        throw StateError('Dictado demasiado largo; usa frases mas cortas');
      return text;
    } finally {
      recording = false;
      lastMilliseconds = elapsed.elapsedMilliseconds;
      try {
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
    _limit?.cancel();
    await _transcribing?.future;
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
