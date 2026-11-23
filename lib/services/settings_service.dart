import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const String _fileName = 'snapnotes_settings.json';
  static const String _tempFileName = 'snapnotes_settings.tmp';

  Future<File> _settingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<File> _tempSettingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_tempFileName');
  }

  Future<AppSettings> loadSettings() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        return const AppSettings();
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const AppSettings();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AppSettings();
      }
      return AppSettings.fromJson(decoded);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final file = await _settingsFile();
    final temp = await _tempSettingsFile();
    await temp.writeAsString(jsonEncode(settings.toJson()), flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await temp.rename(file.path);
  }
}
