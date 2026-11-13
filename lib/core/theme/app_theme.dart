import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SensoryColors.background,
      colorScheme: const ColorScheme.light(
        primary: SensoryColors.primary,
        secondary: SensoryColors.secondary,
        surface: SensoryColors.surface,
        onSurface: SensoryColors.textDark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SensoryColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          fontFamily: 'Outfit', // Uses system font fallback if not loaded
        ),
        titleLarge: TextStyle(
          color: SensoryColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        bodyLarge: TextStyle(color: SensoryColors.textDark, fontSize: 16),
        bodyMedium: TextStyle(color: SensoryColors.textLight, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: SensoryColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SensoryColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: SensoryColors.primary,
        secondary: SensoryColors.secondary,
        surface: SensoryColors.surfaceDark,
        onSurface: SensoryColors.textDarkSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SensoryColors.textDarkSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          fontFamily: 'Outfit',
        ),
        titleLarge: TextStyle(
          color: SensoryColors.textDarkSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        bodyLarge: TextStyle(
          color: SensoryColors.textDarkSecondary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: SensoryColors.textLightSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: SensoryColors.surfaceDark,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
