import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.primaryPurple,
      onPrimary: Colors.white,

      secondary: AppColors.deepPurple,
      onSecondary: Colors.white,

      surface: Colors.white,
      onSurface: AppColors.textPrimary,

      onSurfaceVariant: AppColors.textSecondary,

      primaryContainer: AppColors.lightPurple,

      error: AppColors.expense,
      onError: Colors.white,

      outlineVariant: AppColors.divider,
    );

    return _baseTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      dividerColor: AppColors.divider,
    );
  }

  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: Color(0xFFA78BFA),
      onPrimary: Color(0xFF21133F),

      secondary: Color(0xFFC4B5FD),
      onSecondary: Color(0xFF21133F),

      surface: Color(0xFF1D1922),
      onSurface: Color(0xFFF5F1F7),

      onSurfaceVariant: Color(0xFFBEB6C3),

      primaryContainer: Color(0xFF35274E),

      error: Color(0xFFFF6B6B),
      onError: Color(0xFF3B0808),

      outlineVariant: Color(0xFF3D3542),
    );

    return _baseTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackground: const Color(0xFF141116),
      dividerColor: const Color(0xFF3D3542),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color dividerColor,
  }) {
    return ThemeData(
      useMaterial3: true,

      brightness: brightness,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: scaffoldBackground,

      dividerColor: dividerColor,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF312B35)
            : const Color(0xFF2E2930),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
