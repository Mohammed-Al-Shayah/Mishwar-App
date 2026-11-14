import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/mishwar_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, MishwarColors.light);
  static ThemeData dark() => _build(Brightness.dark, MishwarColors.dark);

  static ThemeData _build(Brightness brightness, MishwarColors colors) {
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.largeTitle,
      displayMedium: AppTextStyles.largeTitle,
      displaySmall: AppTextStyles.largeTitle,
      headlineLarge: AppTextStyles.largeTitle,
      headlineMedium: AppTextStyles.title1,
      headlineSmall: AppTextStyles.title2,
      titleLarge: AppTextStyles.title1,
      titleMedium: AppTextStyles.headline,
      titleSmall: AppTextStyles.subhead,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.footnote,
      labelLarge: AppTextStyles.headline,
      labelMedium: AppTextStyles.subhead,
      labelSmall: AppTextStyles.caption,
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder);
    final buttonSize = Size.fromHeight(AppSizes.buttonHeight);
    final monochromeButton = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
      textStyle: WidgetStatePropertyAll(AppTextStyles.headline),
      minimumSize: WidgetStatePropertyAll(buttonSize),
      shape: WidgetStatePropertyAll(shape),
      overlayColor: WidgetStatePropertyAll(
        colors.textPrimary.withValues(alpha: 0.08),
      ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      extensions: [colors],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primaryButton,
        onPrimary: colors.onPrimaryButton,
        secondary: colors.textPrimary,
        onSecondary: colors.background,
        error: colors.negative,
        onError: AppColors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        surfaceContainerLowest: colors.background,
        surfaceContainerLow: colors.sheet,
        surfaceContainer: colors.fillSubtle,
        surfaceContainerHigh: colors.fill,
        surfaceContainerHighest: colors.fill,
        outline: colors.textInactive,
        outlineVariant: colors.divider,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textPrimary, size: AppSizes.icon),
      splashFactory: InkRipple.splashFactory,
      splashColor: colors.textPrimary.withValues(alpha: 0.08),
      highlightColor: colors.textPrimary.withValues(alpha: 0.04),
      filledButtonTheme: FilledButtonThemeData(
        style: monochromeButton.copyWith(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colors.grabber;
            if (states.contains(WidgetState.pressed)) {
              return brightness == Brightness.light
                  ? AppColors.primaryPressed
                  : AppColors.grey200;
            }
            return colors.primaryButton;
          }),
          foregroundColor: WidgetStatePropertyAll(colors.onPrimaryButton),
          overlayColor: WidgetStatePropertyAll(
            colors.onPrimaryButton.withValues(alpha: 0.08),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: monochromeButton.copyWith(
          side: WidgetStatePropertyAll(BorderSide(color: colors.textPrimary)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: monochromeButton),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.fill,
        hintStyle: AppTextStyles.headline.copyWith(color: colors.textSecondary),
        contentPadding: EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.pillBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBorder,
          borderSide: BorderSide.none,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.sheet,
        modalBackgroundColor: colors.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetBorder),
        showDragHandle: true,
        dragHandleColor: colors.grabber,
        dragHandleSize: Size(AppSizes.grabberWidth, AppSizes.grabberHeight),
        elevation: 2,
        modalElevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.08),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: AppSizes.divider,
        space: AppSizes.divider,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: AppSizes.bottomNavHeight,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textInactive,
            size: AppSizes.icon,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textInactive,
          ),
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headline.copyWith(
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
