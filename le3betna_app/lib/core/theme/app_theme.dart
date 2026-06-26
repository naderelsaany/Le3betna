import 'package:flutter/material.dart';

/// Design System for Le3betna (Premium Dark Mode)
class AppTheme {
  // Colors (Linear/Stripe inspired dark mode)
  static const Color background = Color(0xFF08090A);
  static const Color surface = Color(0xFF0F1011);
  static const Color surfaceHover = Color(0xFF16181A);
  
  // Accents
  static const Color accentPrimary = Color(0xFF5E6AD2);
  static const Color accentSecondary = Color(0xFFEF4444); // Tomato Red for Egyptian flavor
  
  // Text
  static const Color textPrimary = Color(0xFFF7F8F8);
  static const Color textSecondary = Color(0xFFA1A1AA);

  // Borders
  static const Color borderSubtle = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const Color borderStrong = Color(0x29FFFFFF); // rgba(255, 255, 255, 0.16)

  // Typography
  static const String fontFamily = 'Inter';

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentPrimary,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1.0),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 18, height: 1.5),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 16, height: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: fontFamily, letterSpacing: -0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: fontFamily),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
