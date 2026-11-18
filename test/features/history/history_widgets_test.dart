import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/get_week_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_screen.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_bar_chart.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';
import '../driver/presence/driver_home_screen_test.dart'
    as driver_test
    show wrap;
import '../driver/presence/driver_home_screen_test.dart'
    show MockHomeEarnings, MockPresenceBloc, map;
import 'history_data_cubit_test.dart';

Widget historyWrap(
  Widget child, {
  String language = 'en',
  bool dark = false,
  GoRouter? router,
}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (_, _) {
    Widget builder(BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.3),
        disableAnimations: true,
      ),
      child: child!,
    );
    return router == null
        ? MaterialApp(
            locale: Locale(language),
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: builder,
            home: child,
          )
        : MaterialApp.router(
            locale: Locale(language),
            theme: AppTheme.light(),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: builder,
            routerConfig: router,
          );
  },
);
void historySize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
    registerFallbackValue(RideParty.rider);
    registerFallbackValue(Cursor());
  });
  for (final language in ['ar', 'en']) {
    testWidgets(
      'history list, empty, retry and refresh $language at scale 1.3',
      (tester) async {
        historySize(tester);
        final repository = MockRides();
        when(
          () => repository.history(party: RideParty.rider, uid: 'u'),
        ).thenAnswer(
          (_) async => Right(RideHistoryPage(items: [historyRide('1')])),
        );
        final cubit = RideHistoryCubit(
          GetRideHistory(repository),
          watchScheduledRides: emptyScheduledRidesWatch(),
          cancelRide: cancelRideStub(),
        );
        addTearDown(() => tester.runAsync(cubit.close));
        await cubit.loadFirst('u');
        await tester.pumpWidget(
          historyWrap(
            BlocProvider.value(value: cubit, child: const RideHistoryScreen()),
            language: language,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HistoryRideRow), findsOneWidget);
        expect(find.text('Dropoff'), findsOneWidget);
        expect(find.text('JD 2.55'), findsOneWidget);
        expect(tester.takeException(), isNull);
        when(
          () => repository.history(party: RideParty.rider, uid: 'u'),
        ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
        await cubit.refresh();
        await tester.pumpAndSettle();

        // Retry uses the existing localized label.
        expect(
          find.text(language == 'ar' ? 'حاول مرة ثانية' : 'Try again'),
          findsOneWidget,
        );

        when(
          () => repository.history(party: RideParty.rider, uid: 'u'),
        ).thenAnswer((_) async => Right(RideHistoryPage(items: [])));
        await tester.tap(
          find.widgetWithText(
            TextButton,
            language == 'ar' ? 'حاول مرة ثانية' : 'Try again',
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(language == 'ar' ? 'ما عندك مشاوير لسا' : 'No trips yet'),
          findsOneWidget,
        );
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();
        verify(
          () => repository.history(party: RideParty.rider, uid: 'u'),
        ).called(greaterThanOrEqualTo(4));
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('receipt $language with rating, car, cash and rebooking', (
      tester,
    ) async {
      historySize(tester);
      final ride = historyRide('1');
      Object? rebooked;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(body: RideReceiptContent(ride: ride)),
          ),
          GoRoute(
            path: '/rider/confirm',
            builder: (_, state) {
              rebooked = state.extra;
              return const Scaffold();
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        historyWrap(const SizedBox(), language: language, router: router),
      );
      await tester.pumpAndSettle();
      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('12-345'), findsOneWidget);
      expect(find.text('JD 2.55'), findsNWidgets(2));
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(rebooked, ride.draft);
      expect(tester.takeException(), isNull);
    });
    testWidgets('dark earnings chart day selection $language', (tester) async {
      historySize(tester);
      final earnings = MockEarnings();
      final rides = MockRides();
      final end = DateTime.utc(2026, 11, 17);
      final days = List.generate(
        7,
        (i) => DailyEarnings(
          day: end.subtract(Duration(days: 6 - i)),
          totalFils: i * 1000,
          trips: i,
        ),
      );
      when(() => earnings.week('u', end)).thenAnswer((_) async => Right(days));
      when(
        () => earnings.watchDay('u', any()),
      ).thenAnswer((_) => const Stream.empty());
      when(() => rides.history(party: RideParty.driver, uid: 'u')).thenAnswer(
        (_) async => Right(RideHistoryPage(items: [historyRide('1')])),
      );
      final cubit = EarningsScreenCubit(
        GetWeekEarnings(earnings),
        WatchDayEarnings(earnings),
        GetRideHistory(rides),
      );
      addTearDown(() => tester.runAsync(cubit.close));
      await cubit.load('u', endingOn: end);
      await tester.pumpWidget(
        historyWrap(
          BlocProvider.value(
            value: cubit,
            child: const DriverEarningsScreen(uid: 'u'),
          ),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('JD 6.00'), findsOneWidget);
      final chart = find.byType(EarningsBarChart);
      expect(chart, findsOneWidget);
      final bars = find.descendant(of: chart, matching: find.byType(InkWell));
      expect(bars, findsNWidgets(7));
      await tester.runAsync(() => tester.tap(bars.first));
      await tester.pumpAndSettle();
      expect(cubit.state.selected, days.first.day);
      expect(find.text('JD 0.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('driver home pill renders live updates', (tester) async {
    historySize(tester);
    final live = StreamController<DriverEarningsState>.broadcast();
    final earnings = MockHomeEarnings();
    whenListen(
      earnings,
      live.stream,
      initialState: const DriverEarningsState(),
    );
    final presence = MockPresenceBloc();
    whenListen(
      presence,
      const Stream<DriverPresenceState>.empty(),
      initialState: const DriverPresenceState(),
    );
    await tester.pumpWidget(
      driver_test.wrap(
        BlocProvider<DriverPresenceBloc>.value(
          value: presence,
          child: BlocProvider<DriverEarningsCubit>.value(
            value: earnings,
            child: const DriverHomeScreen(uid: 'u', mapBuilder: map),
          ),
        ),
      ),
    );
    live.add(
      DriverEarningsState(
        earnings: DailyEarnings(day: DateTime.utc(2026), totalFils: 12500),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('JD 12.50'), findsOneWidget);
    live.add(
      DriverEarningsState(
        earnings: DailyEarnings(day: DateTime.utc(2026), totalFils: 15000),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('JD 15.00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await live.close();
  });
}
