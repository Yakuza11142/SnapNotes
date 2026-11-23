import 'local_storage_backend_stub.dart'
    if (dart.library.io) 'local_storage_backend_io.dart';

abstract class LocalStorageBackend {
  factory LocalStorageBackend() => createLocalStorageBackend();

  Future<String?> readRawNotes();
  Future<void> writeRawNotes(String payload);
}
