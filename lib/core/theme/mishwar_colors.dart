import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_colors.dart';

@immutable
class MishwarColors extends ThemeExtension<MishwarColors> {
  const MishwarColors({
    required this.background,
    required this.surface,
    required this.sheet,
    required this.fill,
    required this.fillSubtle,
    required this.divider,
    required this.grabber,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInactive,
    required this.primaryButton,
    required this.onPrimaryButton,
    required this.route,
    required this.cash,
    required this.positive,
    required this.negative,
    required this.info,
    required this.brand,
  });

  static const light = MishwarColors(
    background: AppColors.white,
    surface: AppColors.white,
    sheet: AppColors.white,
    fill: AppColors.grey100,
    fillSubtle: AppColors.grey50,
    divider: AppColors.grey200,
    grabber: AppColors.grey300,
    textPrimary: AppColors.black,
    textSecondary: AppColors.grey600,
    textInactive: AppColors.grey500,
    primaryButton: AppColors.black,
    onPrimaryButton: AppColors.white,
    route: AppColors.black,
    cash: AppColors.cash,
    positive: AppColors.positive,
    negative: AppColors.negative,
    info: AppColors.info,
    brand: AppColors.brand,
  );

  static const dark = MishwarColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSheet,
    sheet: AppColors.darkSheet,
    fill: AppColors.darkFill,
    fillSubtle: AppColors.darkFill,
    divider: AppColors.darkFill,
    grabber: AppColors.grey600,
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey300,
    textInactive: AppColors.grey500,
    primaryButton: AppColors.white,
    onPrimaryButton: AppColors.black,
    route: AppColors.white,
    cash: AppColors.cash,
    positive: AppColors.positive,
    negative: AppColors.negative,
    info: AppColors.info,
    brand: AppColors.brand,
  );

  final Color background;
  final Color surface;
  final Color sheet;
  final Color fill;
  final Color fillSubtle;
  final Color divider;
  final Color grabber;
  final Color textPrimary;
  final Color textSecondary;
  final Color textInactive;
  final Color primaryButton;
  final Color onPrimaryButton;
  final Color route;
  final Color cash;
  final Color positive;
  final Color negative;
  final Color info;
  final Color brand;

  @override
  MishwarColors copyWith({
    Color? background,
    Color? surface,
    Color? sheet,
    Color? fill,
    Color? fillSubtle,
    Color? divider,
    Color? grabber,
    Color? textPrimary,
    Color? textSecondary,
    Color? textInactive,
    Color? primaryButton,
    Color? onPrimaryButton,
    Color? route,
    Color? cash,
    Color? positive,
    Color? negative,
    Color? info,
    Color? brand,
  }) => MishwarColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    sheet: sheet ?? this.sheet,
    fill: fill ?? this.fill,
    fillSubtle: fillSubtle ?? this.fillSubtle,
    divider: divider ?? this.divider,
    grabber: grabber ?? this.grabber,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textInactive: textInactive ?? this.textInactive,
    primaryButton: primaryButton ?? this.primaryButton,
    onPrimaryButton: onPrimaryButton ?? this.onPrimaryButton,
    route: route ?? this.route,
    cash: cash ?? this.cash,
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
    info: info ?? this.info,
    brand: brand ?? this.brand,
  );

  @override
  MishwarColors lerp(covariant MishwarColors? other, double t) {
    if (other == null) return this;
    return MishwarColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      fillSubtle: Color.lerp(fillSubtle, other.fillSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      grabber: Color.lerp(grabber, other.grabber, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textInactive: Color.lerp(textInactive, other.textInactive, t)!,
      primaryButton: Color.lerp(primaryButton, other.primaryButton, t)!,
      onPrimaryButton: Color.lerp(onPrimaryButton, other.onPrimaryButton, t)!,
      route: Color.lerp(route, other.route, t)!,
      cash: Color.lerp(cash, other.cash, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      info: Color.lerp(info, other.info, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
    );
  }
}
