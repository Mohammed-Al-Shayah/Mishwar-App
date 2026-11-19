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
import 'package:mishwar/core/widgets/mw_driver_card.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/rating/domain/rate_ride.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/domain/skip_rating.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancellation_quote.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_clock.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_summary_screen.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_tracking_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/rating_mocks.dart';
import '../../../helpers/ride_mocks.dart';
import '../../common/ride/ride_data_test.dart' show rideJson;
import 'ride_tracking_bloc_test.dart' show rideWith;

Future<GoRouter> pumpTracking(
  WidgetTester tester,
  MockRideRepository repository, {
  bool reducedMotion = false,
  double scale = 1,
  String language = 'en',
  bool summary = false,
  Future<Either<Failure, int>>? quote,
}) async {
  when(
    () => repository.cancellationQuote(any()),
  ).thenAnswer((_) => quote ?? Future.value(const Right(0)));
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: summary ? '/rider/ride/ride/summary' : '/rider/ride/ride',
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
        path: '/rider/ride/:id/summary',
        builder: (_, _) => BlocProvider(
          create: (_) => RideTrackingBloc(
            WatchRide(repository),
            CancelRide(repository),
            'ride',
            WatchDriverLocation(repository),
            RideTrackingClock(),
            CancellationQuote(repository),
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<RatingCubit>(
                create: (_) => RatingCubit(
                  RateRide(repository),
                  SkipRating(repository),
                  'ride',
                  RatingSide.rider,
                ),
              ),
              BlocProvider<SessionCubit>(create: (_) => readyRatingSession()),
            ],
            child: const RideSummaryScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/rider/ride/:id',
        builder: (_, _) => BlocProvider(
          create: (_) => RideTrackingBloc(
            WatchRide(repository),
            CancelRide(repository),
            'ride',
            WatchDriverLocation(repository),
            RideTrackingClock(),
            CancellationQuote(repository),
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

RideEntity liveRide(RideStatus status, {int? finalMinor}) =>
    RideModel.fromJson({
      ...rideJson(),
      'status': 'accepted',
      'driverId': 'driver',
      'driverInfo': {
        'name': 'Ahmad',
        'phone': '+962780000002',
        'rating': 4.9,
        'vehicle': {
          'type': 'economy',
          'make': 'Toyota',
          'model': 'Corolla',
          'color': 'White',
          'plate': '12-34567',
        },
      },
      'route': {'polyline': '', 'distanceMeters': 1000, 'durationSeconds': 600},
      'fare': {
        'estimated': 2.55,
        'final': finalMinor == null ? null : finalMinor / 1000,
        'currency': 'JOD',
      },
    }).copyWith(status: status).toEntity();
void main() {
  late MockRideRepository repository;
  setUp(() {
    repository = MockRideRepository();
    when(
      () => repository.watchDriverLocation(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.cancelRide('ride'),
    ).thenAnswer((_) async => const Right(CancelRideResult()));
  });
  for (final language in ['ar', 'en']) {
    testWidgets('quote loading and fee confirmation $language at scale 1.3', (
      tester,
    ) async {
      final quote = Completer<Either<Failure, int>>();
      when(() => repository.watchRide('ride')).thenAnswer(
        (_) => Stream.value(Right(liveRide(RideStatus.accepted))),
      );
      await pumpTracking(
        tester,
        repository,
        language: language,
        scale: 1.3,
        reducedMotion: true,
        quote: quote.future,
      );
      final cancel = find.text(
        language == 'ar' ? 'إلغاء المشوار' : 'Cancel trip',
      );
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      quote.complete(const Right(500));
      await tester.pumpAndSettle();
      expect(find.textContaining('JD 0.50'), findsOneWidget);
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.showDragHandle, isNot(false));
      await tester.ensureVisible(find.byType(MwPrimaryButton));
      await tester.tap(find.byType(MwPrimaryButton));
      await tester.pumpAndSettle();
      verify(() => repository.cancellationQuote('ride')).called(1);
      verify(() => repository.cancelRide('ride')).called(1);
      expect(tester.takeException(), isNull);
    });
    for (final status in [
      RideStatus.accepted,
      RideStatus.arriving,
      RideStatus.arrived,
      RideStatus.inProgress,
    ]) {
      testWidgets('trip phase $status $language at scale 1.3', (tester) async {
        when(
          () => repository.watchRide('ride'),
        ).thenAnswer((_) => Stream.value(Right(liveRide(status))));
        await pumpTracking(
          tester,
          repository,
          language: language,
          scale: 1.3,
          reducedMotion: true,
        );
        expect(find.byType(MwDriverCard), findsOneWidget);
        expect(find.text('Ahmad'), findsOneWidget);
        final cancel = find.text(
          language == 'ar' ? 'إلغاء المشوار' : 'Cancel trip',
        );
        if (status == RideStatus.inProgress) {
          expect(cancel, findsNothing);
        } else {
          await tester.ensureVisible(cancel);
          await tester.tap(cancel);
          await tester.pumpAndSettle();
          expect(
            find.text(
              language == 'ar'
                  ? 'متأكد بدك تلغي المشوار؟ السائق بالطريق'
                  : 'Cancel this trip? Your driver is on the way',
            ),
            findsOneWidget,
          );
          await tester.tap(find.byType(MwPrimaryButton));
          await tester.pumpAndSettle();
          verify(() => repository.cancelRide('ride')).called(1);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
    testWidgets('summary fare and trip rows $language', (tester) async {
      when(() => repository.watchRide('ride')).thenAnswer(
        (_) => Stream.value(
          Right(liveRide(RideStatus.completed, finalMinor: 5250)),
        ),
      );
      final router = await pumpTracking(
        tester,
        repository,
        language: language,
        scale: 1.3,
        reducedMotion: true,
        summary: true,
      );
      expect(find.text('JD 5.25'), findsOneWidget);
      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Dropoff'), findsOneWidget);
      final stars = tester.widget<MwStarRating>(find.byType(MwStarRating));
      stars.onChanged!(5);
      await tester.pumpAndSettle();
      expect(
        find.text(language == 'ar' ? 'سيارة نظيفة' : 'Clean car'),
        findsOneWidget,
      );
      tester.widget<MwStarRating>(find.byType(MwStarRating)).onChanged!(2);
      await tester.pumpAndSettle();
      expect(
        find.text(language == 'ar' ? 'سيارة مش نظيفة' : 'Dirty car'),
        findsOneWidget,
      );
      expect(
        find.text(language == 'ar' ? 'سيارة نظيفة' : 'Clean car'),
        findsNothing,
      );
      when(
        () => repository.skipRating('ride'),
      ).thenAnswer((_) async => const Right(unit));
      final skip = find.text(language == 'ar' ? 'تخطي' : 'Skip');
      await tester.ensureVisible(skip);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/rider');
    });
  }
  testWidgets('completion navigates to summary with estimated fare fallback', (
    tester,
  ) async {
    final updates = StreamController<Either<Failure, RideEntity>>.broadcast();
    addTearDown(updates.close);
    when(() => repository.watchRide('ride')).thenAnswer((_) => updates.stream);
    final router = await pumpTracking(tester, repository, reducedMotion: true);
    updates.add(Right(liveRide(RideStatus.accepted)));
    await tester.pumpAndSettle();
    updates.add(Right(liveRide(RideStatus.completed)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // The summary Bloc obtains its own snapshot subscription.
    updates.add(Right(liveRide(RideStatus.completed)));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/rider/ride/ride/summary',
    );
    expect(find.text('JD 2.55'), findsOneWidget);
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
    'cancelled snapshot returns home and accepted shows ETA',
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
      expect(find.text('Driver arrives in 1 min'), findsOneWidget);
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
