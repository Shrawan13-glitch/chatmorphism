import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF3F3D99);
  static const background = Color(0xFF111118);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFF242440);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9898B0);
  static const accent = Color(0xFF4FC3F7);
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF69F0AE);
  static const sidebarBg = Color(0xFF0E0E1A);
  static const inputBg = Color(0xFF1E1E32);
  static const border = Color(0xFF2A2A45);
  static const bubbleGradientStart = Color(0xFF6C63FF);
  static const bubbleGradientEnd = Color(0xFF8B6FFF);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
      ),
    );
  }
}
