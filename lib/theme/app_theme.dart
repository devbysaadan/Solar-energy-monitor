import 'package:flutter/material.dart';

class AppTheme {
  // Tesla-inspired color palette
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color solarGreen = Color(0xFF3E943C);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color gridBlue = Color(0xFF2C7BE5);
  static const Color batteryYellow = Color(0xFFFACC15);
  static const Color homePurple = Color(0xFF9D4EDD);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: solarGreen,
      colorScheme: const ColorScheme.dark(
        primary: solarGreen,
        surface: surface,
        background: background,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }
}
