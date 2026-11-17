import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fixed artwork ratios; UI dimensions adapt through ScreenUtil.
abstract final class BrandTokens {
  static double get iconSize => 48.r;
  static const iconSafeFraction = 0.66;
  static const iconRadiusFraction = 0.22;
  // Optical centering compensates for the font's Arabic baseline/ascender gap.
  static const glyphOffsetFraction = -0.09;
  static const markFraction = 0.07;
  static const markStartFraction = 0.13;
  static const markTopFraction = 0.07;
}
