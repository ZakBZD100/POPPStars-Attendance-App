import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xff6200ee),
    colorScheme: ColorScheme.light(
      primary: const Color(0xff6200ee),
      secondary: const Color(0xff03dac6),
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff6200ee),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[200],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xffbb86fc),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xffbb86fc),
      secondary: const Color(0xff03dac6),
    ),
    scaffoldBackgroundColor: const Color(0xff121212),
    cardColor: const Color(0xff1f1f1f),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff1f1f1f),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[800],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.purpleAccent),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}
