import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double speechRate;
  final int maxStudyItems;
  final String speechLocale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.speechRate = 0.5,
    this.maxStudyItems = 6,
    this.speechLocale = 'en-US',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? speechRate,
    int? maxStudyItems,
    String? speechLocale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      speechRate: speechRate ?? this.speechRate,
      maxStudyItems: maxStudyItems ?? this.maxStudyItems,
      speechLocale: speechLocale ?? this.speechLocale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'speechRate': speechRate,
      'maxStudyItems': maxStudyItems,
      'speechLocale': speechLocale,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final modeName = json['themeMode'] as String? ?? 'system';
    final parsedMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == modeName,
      orElse: () => ThemeMode.system,
    );

    final rawRate = (json['speechRate'] as num?)?.toDouble() ?? 0.5;
    final rawItems = json['maxStudyItems'] as int? ?? 6;
    final locale = json['speechLocale'] as String? ?? 'en-US';

    return AppSettings(
      themeMode: parsedMode,
      speechRate: rawRate.clamp(0.25, 1.0),
      maxStudyItems: rawItems.clamp(3, 10),
      speechLocale: locale.trim().isEmpty ? 'en-US' : locale.trim(),
    );
  }
}
