import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/mishwar_colors.dart';

extension ThemeX on BuildContext {
  MishwarColors get colors => Theme.of(this).extension<MishwarColors>()!;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
