import 'package:flutter/material.dart';

class SensoryColors {
  // Pastel, low-saturation colors to prevent sensory overload
  static const Color background = Color(0xFFF3F7F9);
  static const Color surface = Colors.white;
  
  static const Color calmBlue = Color(0xFFC6E0EE);
  static const Color calmGreen = Color(0xFFD4EAD0);
  static const Color calmPurple = Color(0xFFD5DEEC); // Glacier slate blue (unisex & soothing)
  static const Color calmPink = Color(0xFFE6DBCB);   // Warm sand / terracota zen (unisex & grounding)
  static const Color calmYellow = Color(0xFFF7ECD5);
  
  // Sophisticated Zen & Scientific Mindfulness Colors (richer contrast for text, icons, buttons & visualizers)
  static const Color zenTeal = Color(0xFF00897B);    // Deep ocean teal (Relajación profunda & Sueño)
  static const Color zenIndigo = Color(0xFF3949AB);  // Tactical slate navy (Enfoque & Box Breathing)
  static const Color zenSage = Color(0xFF2E7D32);    // Heart coherence forest sage (Coherencia Cardíaca)
  static const Color zenAmber = Color(0xFFD84315);   // Energizing sunset amber (Suspiro Fisiológico / Alerta)
  static const Color zenCyan = Color(0xFF0097A6);    // Mineral aegean cyan (Calma fisiológica rápida)
  
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  
  // Dark mode specific colors
  static const Color backgroundDark = Color(0xFF14191D);
  static const Color surfaceDark = Color(0xFF1E252B);
  static const Color textDarkSecondary = Color(0xFFECEFF1);
  static const Color textLightSecondary = Color(0xFF90A4AE);
  
  static const Color primary = Color(0xFF5B8A72); // Refined deep sage green
  static const Color secondary = Color(0xFF627A95); // Refined slate blue
  static const Color error = Color(0xFFE53935); // Centralized error/danger color
  
  static const List<Color> gameColors = [
    calmBlue,
    calmGreen,
    calmPurple,
    calmPink,
    calmYellow,
  ];
}
