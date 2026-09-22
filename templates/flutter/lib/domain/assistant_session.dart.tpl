import 'dart:convert';

class AssistantSession {
  int generation = 0;
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _evidence = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);
  List<Map<String, dynamic>> get evidence => List.unmodifiable(_evidence);
  String? pendingInstruction;
  String? pendingQuestion;
  String? mode;
  Map<String, dynamic>? pendingDraft;

  void add(String role, String text) {
    _messages.add({'role': role, 'text': text});
    while (_messages.length > 24) {
      _messages.removeAt(0);
    }
  }

  void remember(Map<String, dynamic> result) {
    _evidence.add(Map<String, dynamic>.unmodifiable(result));
    while (_evidence.length > 6) {
      _evidence.removeAt(0);
    }
  }

  List<Map<String, dynamic>> recent(int maxBytes) {
    final result = <Map<String, dynamic>>[];
    var size = 0;
    for (final entry in _messages.reversed) {
      final bytes = utf8.encode(jsonEncode(entry)).length;
      if (size + bytes > maxBytes) break;
      result.insert(0, entry);
      size += bytes;
    }
    return result;
  }

  void clear() {
    generation++;
    _messages.clear();
    _evidence.clear();
    pendingInstruction = null;
    pendingQuestion = null;
    mode = null;
    pendingDraft = null;
  }
}
