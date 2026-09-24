import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF05060D);
  static const ink = Color(0xFF12162A);
  static const ink2 = Color(0xFF1B2140);
  static const card = Color(0xFF1F2647);
  static const cardHi = Color(0xFF262E54);
  static const text = Color(0xFFECEDF3);
  static const dim = Color(0xFF9298B8);
  static const faint = Color(0xFF6A6F94);
  static const accent = Color(0xFFFF6A3D);
  static const teal = Color(0xFF2ED1B0);
  static const amber = Color(0xFFFFC352);
}

ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.teal,
          surface: AppColors.card),
      fontFamily: 'Inter',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: const TextStyle(color: AppColors.faint),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent)),
      ),
    );
