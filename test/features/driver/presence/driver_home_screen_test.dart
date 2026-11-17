import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_en.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../offer/driver_offer_bloc_test.dart' show MockOfferBloc;

class MockHomeEarnings extends MockCubit<DriverEarningsState>
    implements DriverEarningsCubit {}

MockHomeEarnings homeEarnings() {
  final cubit = MockHomeEarnings();
  whenListen(
    cubit,
    const Stream<DriverEarningsState>.empty(),
    initialState: DriverEarningsState(
      earnings: DailyEarnings(day: DateTime.utc(2026)),
    ),
  );
  when(() => cubit.start(any())).thenAnswer((_) async {});
  return cubit;
}

class MockPresenceBloc
    extends MockBloc<DriverPresenceEvent, DriverPresenceState>
    implements DriverPresenceBloc {}

Widget wrap(Widget child, {String language = 'ar'}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (_, _) => MaterialApp(
    locale: Locale(language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.3),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: BlocProvider<offer.DriverOfferBloc>(
      create: (_) {
        final bloc = MockOfferBloc();
        whenListen(
          bloc,
          const Stream<offer.DriverOfferState>.empty(),
          initialState: const offer.DriverOfferState(),
        );
        return bloc;
      },
      child: BlocProvider<DriverEarningsCubit>(
        create: (_) => homeEarnings(),
        child: child,
      ),
    ),
  ),
);
Widget map(BuildContext context) =>
    ColoredBox(key: const Key('driver_map'), color: context.colors.background);
void size(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() => registerFallbackValue(const GoOnlinePressed()));
  for (final language in ['ar', 'en']) {
    final l10n = language == 'ar' ? AppLocalizationsAr() : AppLocalizationsEn();
    for (final online in [false, true]) {
      testWidgets('driver view $language online=$online at text scale 1.3', (
        tester,
      ) async {
        size(tester);
        final bloc = MockPresenceBloc();
        whenListen(
          bloc,
          const Stream<DriverPresenceState>.empty(),
          initialState: DriverPresenceState(
            status: online ? PresenceStatus.online : PresenceStatus.offline,
            isOnline: online,
          ),
        );
        await tester.pumpWidget(
          wrap(
            BlocProvider<DriverPresenceBloc>.value(
              value: bloc,
              child: const DriverHomeScreen(uid: 'd', mapBuilder: map),
            ),
            language: language,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(online ? l10n.driverOnline : l10n.driverOffline),
          findsOneWidget,
        );
        expect(find.text(l10n.driverEarningsAmount), findsOneWidget);
        expect(
          find.byKey(const Key('driver_start')),
          online ? findsNothing : findsOneWidget,
        );
        final context = tester.element(find.byKey(const Key('driver_map')));
        expect(Theme.of(context).brightness, Brightness.dark);
        expect(tester.takeException(), isNull);
        if (!online) {
          await tester.tap(find.byKey(const Key('driver_start')));
          verify(() => bloc.add(any(that: isA<GoOnlinePressed>()))).called(1);
        }
      });
    }
    testWidgets('offline requires confirmation $language', (tester) async {
      size(tester);
      final bloc = MockPresenceBloc();
      whenListen(
        bloc,
        const Stream<DriverPresenceState>.empty(),
        initialState: const DriverPresenceState(
          status: PresenceStatus.online,
          isOnline: true,
        ),
      );
      await tester.pumpWidget(
        wrap(
          BlocProvider<DriverPresenceBloc>.value(
            value: bloc,
            child: const DriverHomeScreen(uid: 'd', mapBuilder: map),
          ),
          language: language,
        ),
      );
      await tester.tap(find.byKey(const Key('driver_stop')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.driverStopConfirm), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<GoOfflinePressed>())));
      await tester.tap(find.text(l10n.driverKeepOnline));
      await tester.pumpAndSettle();
      verifyNever(() => bloc.add(any(that: isA<GoOfflinePressed>())));
      await tester.tap(find.byKey(const Key('driver_stop')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.driverStop).last);
      await tester.pumpAndSettle();
      verify(() => bloc.add(any(that: isA<GoOfflinePressed>()))).called(1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('permission denied shows settings action $language', (
      tester,
    ) async {
      size(tester);
      final bloc = MockPresenceBloc();
      whenListen(
        bloc,
        const Stream<DriverPresenceState>.empty(),
        initialState: const DriverPresenceState(
          status: PresenceStatus.permissionDenied,
        ),
      );
      when(bloc.openSettings).thenAnswer((_) async {});
      await tester.pumpWidget(
        wrap(
          BlocProvider<DriverPresenceBloc>.value(
            value: bloc,
            child: const DriverHomeScreen(uid: 'd', mapBuilder: map),
          ),
          language: language,
        ),
      );
      expect(find.text(l10n.locationPermissionHint), findsOneWidget);
      await tester.tap(find.text(l10n.openSettings));
      verify(bloc.openSettings).called(1);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('assigned ride disables offline button', (tester) async {
    size(tester);
    final bloc = MockPresenceBloc();
    whenListen(
      bloc,
      const Stream<DriverPresenceState>.empty(),
      initialState: const DriverPresenceState(
        status: PresenceStatus.online,
        isOnline: true,
        canGoOffline: false,
      ),
    );
    await tester.pumpWidget(
      wrap(
        BlocProvider<DriverPresenceBloc>.value(
          value: bloc,
          child: const DriverHomeScreen(uid: 'd', mapBuilder: map),
        ),
      ),
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('driver_stop')))
          .onPressed,
      isNull,
    );
  });
}
