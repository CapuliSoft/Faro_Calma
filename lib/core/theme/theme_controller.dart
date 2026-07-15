import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  ThemeMode get themeMode => themeModeNotifier.value;

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  void toggleTheme() {
    if (themeModeNotifier.value == ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
  }
}
