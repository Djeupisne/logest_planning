import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
    ),
  );
}
