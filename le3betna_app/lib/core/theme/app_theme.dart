import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System for Le3betna (Premium Dark Mode)
class AppTheme {
  // Primary Brand Colors
  static const Color bgDeep = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgPanel = Color(0xFF16213E);

  // Accents
  static const Color accentRed = Color(0xFFE94560);
  static const Color accentGold = Color(0xFFFFB703);
  static const Color accentTeal = Color(0xFF06D6A0);

  // Player Colors
  static const Color playerRed = Color(0xFFE94560);
  static const Color playerBlue = Color(0xFF4CC9F0);
  static const Color playerYellow = Color(0xFFFFB703);
  static const Color playerGreen = Color(0xFF06D6A0);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const Color textMuted = Color(0x66FFFFFF);     // rgba(255,255,255,0.4)

  // Borders
  static const Color borderTransparent = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Typography TextThemes
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.cairo(color: textPrimary, fontSize: 36, fontWeight: FontWeight.w900),
      displayMedium: GoogleFonts.cairo(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.cairo(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.tajawal(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.tajawal(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.tajawal(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
      labelMedium: GoogleFonts.spaceGrotesk(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      primaryColor: accentRed,
      colorScheme: const ColorScheme.dark(
        primary: accentRed,
        secondary: accentGold,
        surface: bgCard,
        background: bgDeep,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bgDeep,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.cairo(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: Colors.white,
          elevation: 0, // No shadow, replaced by glow in custom widget
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // SM
          ),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0, // No shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // MD
          side: const BorderSide(color: borderTransparent, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bgPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // LG
          side: const BorderSide(color: borderTransparent, width: 1),
        ),
      ),
    );
  }
}
