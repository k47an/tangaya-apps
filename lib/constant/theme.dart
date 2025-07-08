import 'package:flutter/material.dart';
import 'constant.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Neutral.white1,
    colorSchemeSeed: Primary.mainColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Primary.subtleColor,
      foregroundColor: Primary.darkColor,
    ),
  );
}
