import 'package:web/web.dart' as web;

import 'local_storage_backend.dart';

LocalStorageBackend createLocalStorageBackend() => _WebNotesBackend();

class _WebNotesBackend implements LocalStorageBackend {
  static const String _storageKey = 'snapnotes_library_v1';

  @override
  Future<String?> readRawNotes() async {
    return web.window.localStorage.getItem(_storageKey);
  }

  @override
  Future<void> writeRawNotes(String payload) async {
    web.window.localStorage.setItem(_storageKey, payload);
  }
}
