import 'settings_backend_stub.dart'
    if (dart.library.io) 'settings_backend_io.dart';

abstract class SettingsBackend {
  factory SettingsBackend() => createSettingsBackend();

  Future<String?> readRawSettings();
  Future<void> writeRawSettings(String payload);
}
