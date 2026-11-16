import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_tracking_screen.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/ride_mocks.dart';
import 'ride_tracking_bloc_test.dart' show rideWith;

Future<GoRouter> pumpTracking(
  WidgetTester tester,
  MockRideRepository repository, {
  bool reducedMotion = false,
  double scale = 1,
  String language = 'en',
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/rider/ride/ride',
    routes: [
      GoRoute(
        path: '/rider',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/rider/confirm',
        builder: (_, state) =>
            Scaffold(body: Text((state.extra! as RideDraft).dropoff.name)),
      ),
      GoRoute(
        path: '/rider/ride/:id',
        builder: (_, _) => BlocProvider(
          create: (_) => RideTrackingBloc(
            WatchRide(repository),
            CancelRide(repository),
            'ride',
          ),
          child: RideTrackingScreen(
            mapBuilder: (_) => const MwMapPlaceholder(),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reducedMotion,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  late MockRideRepository repository;
  setUp(() {
    repository = MockRideRepository();
    when(
      () => repository.cancelRide('ride'),
    ).thenAnswer((_) async => const Right(unit));
  });
  testWidgets(
    'searching shows rings, summary, rotating copy, and cancel confirmation',
    (tester) async {
      when(
        () => repository.watchRide('ride'),
      ).thenAnswer((_) => Stream.value(Right(rideWith(RideStatus.searching))));
      await pumpTracking(tester, repository);
      expect(find.text('Looking for a nearby driver…'), findsOneWidget);
      expect(find.text('JD 2.55'), findsOneWidget);
      expect(tester.widget<MwMap>(find.byType(MwMap)).circles, hasLength(2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Finding you a Economy'), findsOneWidget);
      final cancel = find.text('Cancel request');
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cancel your request?'), findsOneWidget);
      await tester.tap(find.text('Keep looking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      verifyNever(() => repository.cancelRide('ride'));
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byType(MwPrimaryButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      verify(() => repository.cancelRide('ride')).called(1);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('no drivers retry carries the same draft to confirmation', (
    tester,
  ) async {
    when(
      () => repository.watchRide('ride'),
    ).thenAnswer((_) => Stream.value(Right(rideWith(RideStatus.noDrivers))));
    final router = await pumpTracking(tester, repository);
    expect(find.text('No nearby drivers found'), findsOneWidget);
    final retry = find.text('Try again');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/rider/confirm');
    expect(find.text('Dropoff'), findsOneWidget);
  });
  testWidgets(
    'cancelled snapshot returns home and accepted shows placeholder',
    (tester) async {
      final updates = StreamController<Either<Failure, RideEntity>>();
      addTearDown(updates.close);
      when(
        () => repository.watchRide('ride'),
      ).thenAnswer((_) => updates.stream);
      final router = await pumpTracking(tester, repository);
      updates.add(Right(rideWith(RideStatus.accepted)));
      await tester.pump();
      await tester.pump();
      expect(find.text('We found a driver!'), findsOneWidget);
      updates.add(Right(rideWith(RideStatus.cancelled)));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/rider');
    },
  );
  testWidgets(
    'Arabic enlarged text and reduced motion keep search static and scrollable',
    (tester) async {
      when(
        () => repository.watchRide('ride'),
      ).thenAnswer((_) => Stream.value(Right(rideWith(RideStatus.searching))));
      await pumpTracking(
        tester,
        repository,
        reducedMotion: true,
        scale: 1.3,
        language: 'ar',
      );
      final before = tester
          .widget<MwMap>(find.byType(MwMap))
          .circles
          .map((c) => c.radius)
          .toList();
      await tester.pump(const Duration(seconds: 4));
      expect(
        tester
            .widget<MwMap>(find.byType(MwMap))
            .circles
            .map((c) => c.radius)
            .toList(),
        before,
      );
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.5,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
