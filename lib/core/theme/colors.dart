import 'package:flutter/material.dart';

class SensoryColors {
  // Pastel, low-saturation colors to prevent sensory overload
  static const Color background = Color(0xFFF3F7F9);
  static const Color surface = Colors.white;
  
  static const Color calmBlue = Color(0xFFD0E8F2);
  static const Color calmGreen = Color(0xFFDDF2D1);
  static const Color calmPurple = Color(0xFFE8DFF5);
  static const Color calmPink = Color(0xFFFCE1E4);
  static const Color calmYellow = Color(0xFFFCF4DD);
  
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  
  // Dark mode specific colors
  static const Color backgroundDark = Color(0xFF14191D);
  static const Color surfaceDark = Color(0xFF1E252B);
  static const Color textDarkSecondary = Color(0xFFECEFF1);
  static const Color textLightSecondary = Color(0xFF90A4AE);
  
  static const Color primary = Color(0xFF9FB8AD); // Soft sage green
  static const Color secondary = Color(0xFF8FA0B3); // Soft slate blue
  
  static const List<Color> gameColors = [
    calmBlue,
    calmGreen,
    calmPurple,
    calmPink,
    calmYellow,
  ];
}
