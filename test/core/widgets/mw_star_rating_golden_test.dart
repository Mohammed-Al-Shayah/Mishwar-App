import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';

Widget wrap(Widget child, {bool dark = false, String language = 'ar'}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );
void main() {
  setUpAll(() async {
    await (FontLoader(
      'PhosphorRegular',
    )..addFont(rootBundle.load('assets/fonts/phosphor/Phosphor.ttf'))).load();
  });
  for (final dark in [false, true]) {
    testWidgets('star rating golden dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: RepaintBoundary(
                key: const Key('stars'),
                child: ColoredBox(
                  color: context.colors.background,
                  child: MwStarRating(value: 3, onChanged: (_) {}),
                ),
              ),
            ),
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('stars')),
        matchesGoldenFile(
          dark ? 'goldens/stars_dark.png' : 'goldens/stars_light.png',
        ),
      );
    });
  }
  for (final language in ['ar', 'en']) {
    testWidgets('tap, drag, semantics and haptics $language', (tester) async {
      var selected = 0;
      final clicks = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          clicks.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) => MwStarRating(
              value: selected,
              onChanged: (n) => setState(() => selected = n),
            ),
          ),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('mw_star_4')));
      await tester.pump();
      expect(selected, 4);
      expect(
        find.bySemanticsLabel(language == 'ar' ? '4 من 5' : '4 out of 5'),
        findsWidgets,
      );
      expect(
        clicks.any(
          (c) =>
              c.method == 'HapticFeedback.vibrate' &&
              c.arguments == 'HapticFeedbackType.selectionClick',
        ),
        isTrue,
      );
      final start = tester.getCenter(find.byKey(const ValueKey('mw_star_1')));
      final end = tester.getCenter(find.byKey(const ValueKey('mw_star_5')));
      await tester.dragFrom(start, end - start);
      await tester.pump();
      expect(selected, 5);
      await tester.dragFrom(end, start - end);
      await tester.pump();
      expect(selected, 1);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('disabled rating ignores gestures', (tester) async {
    await tester.pumpWidget(
      wrap(const MwStarRating(value: 2, onChanged: null)),
    );
    await tester.tap(find.byKey(const ValueKey('mw_star_5')));
    await tester.pump();
    expect(tester.widget<MwStarRating>(find.byType(MwStarRating)).value, 2);
  });
}
