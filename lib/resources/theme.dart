import 'package:flutter/material.dart';
import 'package:my_prayer/resources/app_color.dart';

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
}
