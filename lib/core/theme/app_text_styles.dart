import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'IBMPlexSansArabic';

  static TextStyle get largeTitle =>
      _style(28, 36, FontWeight.w700).copyWith(letterSpacing: -0.5);
  static TextStyle get title1 =>
      _style(24, 32, FontWeight.w700).copyWith(letterSpacing: -0.5);
  static TextStyle get title2 => _style(18, 24, FontWeight.w600);
  static TextStyle get headline => _style(16, 22, FontWeight.w600);
  static TextStyle get body => _style(16, 24, FontWeight.w400);
  static TextStyle get subhead => _style(14, 20, FontWeight.w500);
  static TextStyle get footnote => _style(13, 18, FontWeight.w400);
  static TextStyle get caption => _style(11, 14, FontWeight.w500);

  static TextStyle tabular(TextStyle style) => style.copyWith(
    fontFeatures: [...?style.fontFeatures, const FontFeature.tabularFigures()],
  );

  static TextStyle _style(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size.sp,
        height: lineHeight / size,
        fontWeight: weight,
      );
}
