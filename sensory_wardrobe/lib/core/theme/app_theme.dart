import 'package:flutter/material.dart';

/// Sensory Wardrobe design system.
/// Colors drawn from the project presentation palette.
class AppColors {
  // Primary brand palette
  static const navy = Color(0xFF1C2B4A);
  static const teal = Color(0xFF028090);
  static const mint = Color(0xFF02C39A);
  static const lightBlue = Color(0xFF2980B9);

  // Neutral
  static const background = Color(0xFFF4F6F8);
  static const cardBorder = Color(0xFFD8E3EC);
  static const textDark = Color(0xFF1C2B4A);
  static const textMid = Color(0xFF4A5568);
  static const textMuted = Color(0xFF7A8FA6);

  // Feedback
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFE67E22);
  static const error = Color(0xFFE74C3C);

  // Comfort rating colors (1–5)
  static const comfortVeryLow = Color(0xFFE74C3C);
  static const comfortLow = Color(0xFFE67E22);
  static const comfortMid = Color(0xFFF1C40F);
  static const comfortHigh = Color(0xFF2ECC71);
  static const comfortVeryHigh = Color(0xFF02C39A);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.light,
          primary: AppColors.teal,
          onPrimary: Colors.white,
          secondary: AppColors.mint,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.teal, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.dark,
          primary: AppColors.teal,
          secondary: AppColors.mint,
        ),
        scaffoldBackgroundColor: const Color(0xFF121C2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1526),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}
