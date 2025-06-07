import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF23262F);
  static const Color secondary = Color(0xFF8E9295);
  static const Color background = Colors.white;

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
      );
}
