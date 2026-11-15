import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishwar/core/theme/app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.08),
      offset: Offset(0, -2.h),
      blurRadius: 12.r,
    ),
  ];
}
