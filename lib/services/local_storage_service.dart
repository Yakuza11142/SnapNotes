import 'dart:convert';

import '../models/study_note.dart';
import 'local_storage_backend.dart';

class LocalStorageService {
  final LocalStorageBackend _backend;

  LocalStorageService({LocalStorageBackend? backend})
      : _backend = backend ?? LocalStorageBackend();

  Future<List<StudyNote>> loadNotes() async {
    try {
      final content = await _backend.readRawNotes();
      if (content == null || content.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(content);
      if (decoded is! List<dynamic>) {
        return const [];
      }

      final notes = decoded
          .whereType>()
          .map(StudyNote.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveNotes(List<StudyNote> notes) async {
    final payload = jsonEncode(notes.map((note) => note.toJson()).toList());
    await _backend.writeRawNotes(payload);
  }
}
