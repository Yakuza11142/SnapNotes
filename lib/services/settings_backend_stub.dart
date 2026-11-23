import 'package:web/web.dart' as web;

import 'settings_backend.dart';

SettingsBackend createSettingsBackend() => _WebSettingsBackend();

class _WebSettingsBackend implements SettingsBackend {
  static const String _storageKey = 'snapnotes_settings_v1';

  @override
  Future<String?> readRawSettings() async {
    return web.window.localStorage.getItem(_storageKey);
  }

  @override
  Future<void> writeRawSettings(String payload) async {
    web.window.localStorage.setItem(_storageKey, payload);
  }
}
