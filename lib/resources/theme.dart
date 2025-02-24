import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF697565), // Surface color
    scaffoldBackgroundColor: Color(0xFF181C14), // Background color
    cardColor: Color(0xFF3C3D37), // Hover color
    hintColor: Color(0xFFECDFCC), // Text color
    dividerColor: Color(0xFF3C3D37), // Hover color for dividers
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Color(0xFFECDFCC), fontSize: 24),
      displayMedium: TextStyle(color: Color(0xFFECDFCC), fontSize: 22),
      displaySmall: TextStyle(color: Color(0xFFECDFCC), fontSize: 20),
      headlineMedium: TextStyle(color: Color(0xFFECDFCC), fontSize: 18),
      headlineSmall: TextStyle(
          color: Color(0xFFECDFCC), fontSize: 16, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: Color(0xFFECDFCC), fontSize: 14),
      bodyLarge: TextStyle(color: Color(0xFFECDFCC), fontSize: 12),
      bodyMedium: TextStyle(color: Color(0xFFECDFCC), fontSize: 10),
    ),
    appBarTheme: AppBarTheme(
      color: Color(0xFF181C14), // Background color
      titleTextStyle:
          TextStyle(color: Color(0xFFECDFCC), fontSize: 20), // Text color
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF3C3D37), // Hover color
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: IconThemeData(
      color: Color(0xFFECDFCC), // Text color
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3C3D37), // Hover color
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF98DED9), // Primary color
    scaffoldBackgroundColor: Color(0xFFEFFFFD), // Background color
    cardColor: Color(0xFFB4ECE8), // Surface color
    hintColor: Color(0xFF181C14), // Text color
    dividerColor: Color(0xFFB4ECE8), // Divider color
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Color(0xFF181C14), fontSize: 24),
      displayMedium: TextStyle(color: Color(0xFF181C14), fontSize: 22),
      displaySmall: TextStyle(color: Color(0xFF181C14), fontSize: 20),
      headlineMedium: TextStyle(color: Color(0xFF181C14), fontSize: 18),
      headlineSmall: TextStyle(
          color: Color(0xFF181C14), fontSize: 16, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: Color(0xFF181C14), fontSize: 14),
      bodyLarge: TextStyle(color: Color(0xFF181C14), fontSize: 12),
      bodyMedium: TextStyle(color: Color(0xFF181C14), fontSize: 10),
    ),
    appBarTheme: AppBarTheme(
      color: Color(0xFFEFFFFD), // Background color
      titleTextStyle:
          TextStyle(color: Color(0xFF181C14), fontSize: 20), // Text color
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFFB4ECE8), // Surface color
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: IconThemeData(
      color: Color(0xFF181C14), // Text color
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFB4ECE8), // Surface color
    ),
  );
}
