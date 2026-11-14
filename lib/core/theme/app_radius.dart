import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppRadius {
  static double get button => 8.r;
  static double get vehicleRow => 10.r;
  static double get tile => 12.r;
  static double get sheet => 16.r;
  static double get pill => 999.r;

  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get vehicleRowBorder => BorderRadius.circular(vehicleRow);
  static BorderRadius get tileBorder => BorderRadius.circular(tile);
  static BorderRadius get sheetBorder => BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}
