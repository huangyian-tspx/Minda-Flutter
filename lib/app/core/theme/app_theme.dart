import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF23262F);
  static const Color secondary = Color(0xFF8E9295);
  static const Color background = Colors.white;
  static const Color chipInactive = Color(0xFFD6EBEB);
  static const Color backButtonColor = Color(0xFFF5F5DC); // Ivory

  static ThemeData get themeData => ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          background: background,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: secondary,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: chipInactive,
          selectedColor: primary,
          disabledColor: chipInactive.withOpacity(0.6),
          secondarySelectedColor: primary.withOpacity(0.1),
          labelStyle: const TextStyle(
            color: primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          brightness: Brightness.light,
          elevation: 0,
          pressElevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
      );
}
