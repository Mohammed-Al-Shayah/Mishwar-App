import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/mishwar_colors.dart';

List<Color> _values(MishwarColors colors) => [
  colors.background,
  colors.surface,
  colors.sheet,
  colors.fill,
  colors.fillSubtle,
  colors.divider,
  colors.grabber,
  colors.textPrimary,
  colors.textSecondary,
  colors.textInactive,
  colors.primaryButton,
  colors.onPrimaryButton,
  colors.route,
  colors.cash,
  colors.positive,
  colors.negative,
  colors.info,
  colors.brand,
];

void main() {
  test('lerp endpoints preserve every light and dark semantic color', () {
    const light = MishwarColors.light;
    const dark = MishwarColors.dark;
    expect(_values(light.lerp(dark, 0)), _values(light));
    expect(_values(light.lerp(dark, 1)), _values(dark));
    expect(_values(light.lerp(null, 0.5)), _values(light));
  });

  test('copyWith replaces specified fields and preserves the rest', () {
    const light = MishwarColors.light;
    final copy = light.copyWith(
      background: AppColors.info,
      brand: AppColors.black,
    );
    expect(_values(copy), [
      AppColors.info,
      ..._values(light).skip(1).take(16),
      AppColors.black,
    ]);
    expect(_values(light.copyWith()), _values(light));
    expect(light.background, AppColors.white);
  });
}
