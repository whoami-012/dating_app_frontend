import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      colorScheme: const ColorScheme.dark(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onBackground: AppColors.darkPrimaryText,
        onSurface: AppColors.darkPrimaryText,
        primary: AppColors.neonLime,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkIcon),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkPrimaryText),
        bodyMedium: TextStyle(color: AppColors.darkSecondaryText),
        titleMedium: TextStyle(color: AppColors.darkPrimaryText),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      colorScheme: const ColorScheme.light(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onBackground: AppColors.lightPrimaryText,
        onSurface: AppColors.lightPrimaryText,
        primary: AppColors.neonLime,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightIcon),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightPrimaryText),
        bodyMedium: TextStyle(color: AppColors.lightSecondaryText),
        titleMedium: TextStyle(color: AppColors.lightPrimaryText),
      ),
    );
  }
}
