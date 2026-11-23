import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_storage_backend.dart';

LocalStorageBackend createLocalStorageBackend() => _IoNotesBackend();

class _IoNotesBackend implements LocalStorageBackend {
  static const String _fileName = 'snapnotes_library.json';
  static const String _tempFileName = 'snapnotes_library.tmp';

  @override
  Future<String?> readRawNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final primaryFile = File('${directory.path}/$_fileName');
    final tempFile = File('${directory.path}/$_tempFileName');

    File? targetFile;
    if (await primaryFile.exists()) {
      targetFile = primaryFile;
    } else if (await tempFile.exists()) {
      targetFile = tempFile;
    }

    return targetFile != null ? await targetFile.readAsString() : null;
  }

  @override
  Future<void> writeRawNotes(String payload) async {
    final directory = await getApplicationDocumentsDirectory();
    final primaryFile = File('${directory.path}/$_fileName');
    final tempFile = File('${directory.path}/$_tempFileName');

    await tempFile.writeAsString(payload, flush: true);
    if (await primaryFile.exists()) {
      await primaryFile.delete();
    }
    await tempFile.rename(primaryFile.path);
  }
}
