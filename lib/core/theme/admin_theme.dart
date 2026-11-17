import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_theme.dart';

abstract final class AdminTheme {
  static ThemeData light() {
    final theme = AppTheme.light();
    final minimum = WidgetStatePropertyAll(
      Size(AppSizes.buttonHeight, AppSizes.buttonHeight),
    );
    return theme.copyWith(
      textButtonTheme: TextButtonThemeData(
        style: theme.textButtonTheme.style!.copyWith(minimumSize: minimum),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: theme.outlinedButtonTheme.style!.copyWith(minimumSize: minimum),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: theme.filledButtonTheme.style!.copyWith(minimumSize: minimum),
      ),
    );
  }
}
