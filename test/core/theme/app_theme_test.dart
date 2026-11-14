import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/mishwar_colors.dart';

void main() {
  testWidgets('light and dark contain semantic colors and bundled font', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) {
          for (final theme in [AppTheme.light(), AppTheme.dark()]) {
            expect(theme.useMaterial3, isTrue);
            expect(
              theme.extension<MishwarColors>(),
              theme.brightness == Brightness.light
                  ? MishwarColors.light
                  : MishwarColors.dark,
            );
            expect(
              theme.textTheme.bodyLarge?.fontFamily,
              AppTextStyles.fontFamily,
            );
            expect(
              theme.textTheme.titleMedium?.fontFamily,
              AppTextStyles.fontFamily,
            );
            expect(theme.splashFactory, InkRipple.splashFactory);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  });
}
