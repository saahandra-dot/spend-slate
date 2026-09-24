import 'package:flutter/material.dart';

enum AppAppearance {
  system(value: 'system', label: 'System', themeMode: ThemeMode.system),
  light(value: 'light', label: 'Light', themeMode: ThemeMode.light),
  dark(value: 'dark', label: 'Dark', themeMode: ThemeMode.dark);

  final String value;
  final String label;
  final ThemeMode themeMode;

  const AppAppearance({
    required this.value,
    required this.label,
    required this.themeMode,
  });

  static AppAppearance fromValue(String? value) {
    for (final appearance in values) {
      if (appearance.value == value) {
        return appearance;
      }
    }

    return AppAppearance.system;
  }
}
