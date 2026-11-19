import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/market_switcher.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';

import '../ride/ride_data_test.dart' show rideJson;

void main() {
  test('money keeps currency, agorot precision and JOD display half-up', () {
    expect(const Money(2550, 'ILS').toDisplayString(), '₪ 25.50');
    expect(const Money(4700).toDisplayString(), 'JD 4.70');
    expect(const Money(3405).toDisplayString(), 'JD 3.41');
    expect(const Money(100, 'ILS'), isNot(const Money(100)));
  });
  test('ride model converts every fee in agorot and preserves market', () {
    final ride = RideModel.fromJson({
      ...rideJson(),
      'market': 'PS',
      'fare': {
        'estimated': 25.5,
        'final': 26,
        'currency': 'ILS',
        'waitingFee': 0.5,
        'previousBalance': 1.5,
        'discount': 2,
      },
    }).toEntity();
    expect(ride.market, 'PS');
    expect(ride.currency, 'ILS');
    expect(ride.fareEstimatedMinor, 2550);
    expect(ride.fareWaitingFeeMinor, 50);
    expect(ride.farePreviousBalanceMinor, 150);
    expect(ride.discountMinor, 200);
  });
  for (final locale in ['ar', 'en']) {
    for (final market in ['PS', 'JO']) {
      testWidgets(
        'history currency and market switcher $locale $market at 1.3',
        (tester) async {
          final currency = market == 'PS' ? 'ILS' : 'JOD';
          final ride = RideModel.fromJson({
            ...rideJson(),
            'market': market,
            'fare': {'estimated': 25.5, 'currency': currency},
          }).toEntity();
          var selected = market;
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, _) => MaterialApp(
                theme: AppTheme.light(),
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: MediaQuery(
                  data: const MediaQueryData(
                    textScaler: TextScaler.linear(1.3),
                  ),
                  child: Scaffold(
                    body: StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          MarketSwitcher(
                            value: selected,
                            onChanged: (m) => setState(() => selected = m),
                          ),
                          HistoryRideRow(ride: ride, onTap: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(currency == 'ILS' ? '₪ 25.50' : 'JD 25.50'),
            findsOneWidget,
          );
          final other = market == 'PS' ? 'JO' : 'PS';
          final label = locale == 'ar'
              ? (other == 'PS' ? 'فلسطين' : 'الأردن')
              : (other == 'PS' ? 'Palestine' : 'Jordan');
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(selected, other);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
