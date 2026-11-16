import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_countdown_bar.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('countdown three progress values dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            home: Scaffold(
              body: RepaintBoundary(
                key: const Key('bars'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final seconds in [15, 8, 0])
                      MwCountdownBar(remaining: Duration(seconds: seconds)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byKey(const Key('bars')),
        matchesGoldenFile('goldens/countdown_${dark ? 'dark' : 'light'}.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
}
