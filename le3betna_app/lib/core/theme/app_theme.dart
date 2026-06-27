import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Design System for Le3betna (Premium Dark Mode)
class AppTheme {
  // Bridge for backward compatibility with older screens
  static Color get bgDeep => AppColors.background;
  static Color get bgCard => AppColors.card;
  static Color get bgPanel => AppColors.surfaceVariant;

  static Color get accentRed => AppColors.primary;
  static Color get accentGold => AppColors.warning;
  static Color get accentTeal => AppColors.success;

  static Color get playerRed => const Color(0xFFEF4444); // Error
  static Color get playerBlue => const Color(0xFF38BDF8); // Info
  static Color get playerYellow => const Color(0xFFF59E0B); // Warning
  static Color get playerGreen => const Color(0xFF22C55E); // Success

  static Color get textPrimary => AppColors.textPrimary;
  static Color get textSecondary => AppColors.textSecondary;
  static Color get textMuted => AppColors.textDisabled;

  static Color get borderTransparent => AppColors.divider;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0, 
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: AppSpacing.md16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), 
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
    );
  }
}
