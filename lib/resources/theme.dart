import 'package:flutter/material.dart';
import 'package:my_prayer/resources/app_color.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          primary: AppColor.darkPrimary,
          onPrimary: AppColor.darkFourt,
          onSecondary: AppColor.darkFourt,
          seedColor: AppColor.darkPrimary,
          secondary: AppColor.darkSecondary),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkPrimary);

  static ThemeData lightTheme = ThemeData(
      primaryColor: AppColor.lightPrimary,
      colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: AppColor.lightPrimary,
          primary: AppColor.lightPrimary,
          onPrimary: AppColor.lightFourt,
          onSecondary: AppColor.lightFourt,
          secondary: AppColor.lightSecondary),
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.lightPrimary);
}
