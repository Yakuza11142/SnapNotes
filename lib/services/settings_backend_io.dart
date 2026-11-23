import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'settings_backend.dart';

SettingsBackend createSettingsBackend() => _IoSettingsBackend();

class _IoSettingsBackend implements SettingsBackend {
  static const String _fileName = 'snapnotes_settings.json';
  static const String _tempFileName = 'snapnotes_settings.tmp';

  @override
  Future<String?> readRawSettings() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    return await file.exists() ? await file.readAsString() : null;
  }

  @override
  Future<void> writeRawSettings(String payload) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    final temp = File('${dir.path}/$_tempFileName');

    await temp.writeAsString(payload, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await temp.rename(file.path);
  }
}
