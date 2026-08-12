import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primaryPurple = Color(0xFF6C3CE0);
  static const Color deepPurple = Color(0xFF4A1FA8);
  static const Color darkPurple = Color(0xFF241629);
  static const Color lightPurple = Color(0xFFEDE6FF);

  // Background colors
  static const Color background = Color(0xFFF9F8FC);
  static const Color surface = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF211A25);
  static const Color textSecondary = Color(0xFF77717C);
  static const Color textLight = Color(0xFFAAA4AE);

  // Financial colors
  static const Color income = Color(0xFF1976D2);
  static const Color expense = Color(0xFFE33D3D);
  static const Color positive = Color(0xFF16A47A);
  static const Color warning = Color(0xFFF15A24);

  // Chart/category colors
  static const Color blue = Color(0xFF2878D7);
  static const Color green = Color(0xFF18A57C);
  static const Color orange = Color(0xFFF04A18);

  // Borders/dividers
  static const Color divider = Color(0xFFE9E6EE);

  // Home screen gradient
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [
      Color(0xFF7C4AE8),
      Color(0xFF4B20A8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}