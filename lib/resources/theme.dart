import 'package:flutter/material.dart';
import 'package:my_prayer/resources/app_color.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
      primaryColor: AppColor.darkPrimary,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkPrimary);

  // ThemeData(
  //     primaryColor: AppColor.darkPrimary,
  //     textTheme:
  //         TextTheme(headlineLarge: TextStyle(color: AppColor.darkSecondary)));
}
