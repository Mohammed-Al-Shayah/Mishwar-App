import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Desktop dimensions use unscaled ScreenUtil on web.
abstract final class AdminSizes {
  static const minWidth = 1024.0;
  static double get sidebar => 240.w;
  static double get panel => 440.w;
  static double get login => 400.w;
  static double get field => 144.w;
  static double get row => 64.h;
  static double get license => 240.h;
  static double get map => 480.h;
}
