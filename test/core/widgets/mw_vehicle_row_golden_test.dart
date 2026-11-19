import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_vehicle_row.dart';

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
    testWidgets('vehicle selected and unselected dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    for (final selected in [true, false])
                      MwVehicleRow(
                        name: context.l10n.vehicleEconomy,
                        seats: 4,
                        subtitle: context.l10n.arrivalDuration('3:42', 10),
                        tagline: context.l10n.economyTagline,
                        price: context.l10n.fareAmount('JD 4.60'),
                        selected: selected,
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/vehicle_rows_${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
  }
}
