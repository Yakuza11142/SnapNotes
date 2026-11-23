import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/study_note.dart';

class LocalStorageService {
  static const String _fileName = 'snapnotes_library.json';
  static const String _tempFileName = 'snapnotes_library.tmp';

  Future<Directory> _getStorageDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  Future<List<StudyNote>> loadNotes() async {
    try {
      final directory = await _getStorageDirectory();
      final primaryFile = File('${directory.path}/$_fileName');
      final tempFile = File('${directory.path}/$_tempFileName');

      File? targetFile;
      if (await primaryFile.exists()) {
        targetFile = primaryFile;
      } else if (await tempFile.exists()) {
        targetFile = tempFile;
      }

      if (targetFile == null) {
        return const [];
      }

      final content = await targetFile.readAsString();
      if (content.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(content);
      if (decoded is! List<dynamic>) {
        return const [];
      }

      return decoded
          .whereType>()
          .map(StudyNote.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveNotes(List<StudyNote> notes) async {
    final directory = await _getStorageDirectory();
    final primaryFile = File('${directory.path}/$_fileName');
    final tempFile = File('${directory.path}/$_tempFileName');

    final payload = jsonEncode(notes.map((note) => note.toJson()).toList());
    await tempFile.writeAsString(payload, flush: true);

    if (await primaryFile.exists()) {
      await primaryFile.delete();
    }
    await tempFile.rename(primaryFile.path);
  }
}
