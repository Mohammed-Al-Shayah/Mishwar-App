import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_driver_card.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_party_info.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

const driver = RidePartyInfo(
  name: 'أحمد',
  phone: '+962780000002',
  rating: 4.9,
  vehicle: VehicleEntity(
    type: VehicleType.economy,
    make: 'Toyota',
    model: 'Corolla',
    color: 'White',
    plate: '12-34567',
  ),
);
void main() {
  setUpAll(() async {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      await (FontLoader('IBMPlexSansArabic')..addFont(
            rootBundle.load(
              'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-$weight.ttf',
            ),
          ))
          .load();
    }
    await (FontLoader(
      'PhosphorRegular',
    )..addFont(rootBundle.load('assets/fonts/phosphor/Phosphor.ttf'))).load();
  });
  for (final dark in [false, true]) {
    testWidgets('driver card light/dark and injected phone URI dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Uri? called;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => RepaintBoundary(
                  key: const Key('card'),
                  child: ColoredBox(
                    color: context.colors.sheet,
                    child: MwDriverCard(
                      driver: driver,
                      launcher: (uri) async {
                        called = uri;
                        return true;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('card')),
        matchesGoldenFile('goldens/driver_card_${dark ? 'dark' : 'light'}.png'),
      );
      await tester.tap(find.byTooltip('اتصال'));
      await tester.pump();
      expect(called, Uri(scheme: 'tel', path: driver.phone));
      expect(
        tester.widget<Text>(find.text('12-34567')).textDirection,
        TextDirection.ltr,
      );
      final actions = tester.widgetList<IconButton>(find.byType(IconButton));
      expect(actions.where((action) => action.onPressed == null), hasLength(2));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
