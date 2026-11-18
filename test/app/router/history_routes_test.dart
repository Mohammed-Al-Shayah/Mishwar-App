import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_cubit.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/get_week_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_screen.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_screen.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/driver/offer/driver_offer_bloc_test.dart'
    show MockOfferBloc;
import '../../features/driver/presence/driver_home_screen_test.dart'
    show MockPresenceBloc;
import '../../features/driver/presence/driver_presence_bloc_test.dart'
    show driver;
import '../../features/history/history_data_cubit_test.dart';
import '../../features/history/history_widgets_test.dart'
    show historySize, historyWrap;
import '../../helpers/ride_mocks.dart';
import '../../helpers/saved_places_mocks.dart';
import 'rider_search_flow_test.dart' show MockHome, MockRiderHome;

class MockHistorySession extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  final user = UserEntity(
    id: 'u',
    name: 'User',
    phone: '',
    createdAt: DateTime.utc(2026),
  );
  tearDown(getIt.reset);
  setUp(registerSavedPlaces);
  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
    registerFallbackValue(const offer.Started('u'));
    registerFallbackValue(
      const Started(uid: 'u', notificationTitle: '', notificationText: ''),
    );
  });
  test('new routes enforce role, approval and pending-rating priority', () {
    final rider = SessionReady(user.copyWith(role: UserRole.rider));
    final approved = SessionReady(
      user.copyWith(role: UserRole.driver),
      driver: driver(),
    );
    for (final path in [
      '/rider/history',
      '/rider/history/ride',
      '/rider/places',
    ]) {
      expect(sessionRedirect(rider, path), isNull);
      expect(sessionRedirect(approved, path), '/driver');
      expect(sessionRedirect(const SessionSignedOut(), path), '/auth/phone');
      expect(
        sessionRedirect(
          SessionReady(
            user.copyWith(role: UserRole.rider, pendingRatingRideId: 'pending'),
          ),
          path,
        ),
        path == '/rider/places' ? null : '/rider/ride/pending/summary',
      );
    }
    for (final path in ['/driver/earnings', '/driver/history/ride']) {
      expect(sessionRedirect(approved, path), isNull);
      expect(sessionRedirect(rider, path), '/rider');
      expect(sessionRedirect(const SessionSignedOut(), path), '/auth/phone');
      expect(
        sessionRedirect(
          SessionReady(
            user.copyWith(role: UserRole.driver),
            driver: driver(ride: 'active'),
          ),
          path,
        ),
        '/driver/ride/active',
      );
      expect(
        sessionRedirect(
          SessionReady(
            user.copyWith(role: UserRole.driver),
            driver: DriverEntity(
              id: 'u',
              status: DriverStatus.approved,
              isOnline: false,
              vehicle: driver().vehicle,
              pendingRatingRideId: 'pending',
            ),
          ),
          path,
        ),
        '/driver/ride/pending/rate',
      );
      expect(
        sessionRedirect(
          SessionReady(
            user.copyWith(role: UserRole.driver),
            driver: DriverEntity(
              id: 'u',
              status: DriverStatus.pending,
              isOnline: false,
              vehicle: driver().vehicle,
            ),
          ),
          path,
        ),
        '/driver/pending',
      );
    }
  });
  test('support routes enforce rider and approved-driver modes', () {
    final rider = SessionReady(user.copyWith(role: UserRole.rider));
    final approved = SessionReady(
      user.copyWith(role: UserRole.driver),
      driver: driver(),
    );
    for (final suffix in ['', '/new', '/ticket']) {
      expect(sessionRedirect(rider, '/rider/support$suffix'), isNull);
      expect(sessionRedirect(approved, '/driver/support$suffix'), isNull);
      expect(sessionRedirect(rider, '/driver/support$suffix'), '/rider');
      expect(sessionRedirect(approved, '/rider/support$suffix'), '/driver');
      expect(
        sessionRedirect(const SessionSignedOut(), '/rider/support$suffix'),
        '/auth/phone',
      );
    }
  });
  testWidgets('rider Activity tab opens history and a receipt', (tester) async {
    historySize(tester);
    final session = MockHistorySession();
    whenListen(
      session,
      const Stream<SessionState>.empty(),
      initialState: SessionReady(user.copyWith(role: UserRole.rider)),
    );
    final rides = MockRides();
    when(
      () => rides.watchActiveRideId('u'),
    ).thenAnswer((_) => const Stream.empty());
    when(() => rides.history(party: RideParty.rider, uid: 'u')).thenAnswer(
      (_) async => Right(RideHistoryPage(items: [historyRide('ride')])),
    );
    when(
      () => rides.watchRide('ride'),
    ).thenAnswer((_) => Stream.value(Right(historyRide('ride'))));
    getIt
      ..registerFactory<HomeCubit>(() {
        final home = MockHome();
        whenListen(
          home,
          const Stream<SubmissionState>.empty(),
          initialState: const SubmissionState(),
        );
        return home;
      })
      ..registerFactory<RiderHomeCubit>(() {
        final home = MockRiderHome();
        whenListen(
          home,
          const Stream<RiderHomeState>.empty(),
          initialState: const RiderHomeState(),
        );
        when(home.start).thenAnswer((_) async {});
        return home;
      })
      ..registerSingleton<WatchActiveRideId>(WatchActiveRideId(rides))
      ..registerFactory<RideHistoryCubit>(
        () => RideHistoryCubit(
          GetRideHistory(rides),
          watchScheduledRides: emptyScheduledRidesWatch(),
          cancelRide: cancelRideStub(),
        ),
      )
      ..registerFactory<RideReceiptCubit>(
        () => RideReceiptCubit(WatchRide(rides)),
      );
    final refresh = SessionRouterRefresh(session.stream);
    final router = createAppRouter(
      session,
      refresh,
      riderMapBuilder: (_) => const SizedBox(),
    )..go('/rider');
    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: session,
        child: historyWrap(const SizedBox(), router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/rider/history');
    expect(find.byType(RideHistoryScreen), findsOneWidget);
    await tester.tap(find.text('Dropoff'));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.path,
      '/rider/history/ride',
    );
    expect(find.byType(RideReceiptScreen), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    refresh.dispose();
    await getIt.reset();
  });

  for (final path in ['/driver/earnings', '/driver/history/ride']) {
    testWidgets('approved deep link $path builds inside driver shell', (
      tester,
    ) async {
      historySize(tester);
      final session = MockHistorySession();
      whenListen(
        session,
        const Stream<SessionState>.empty(),
        initialState: SessionReady(
          user.copyWith(role: UserRole.driver),
          driver: driver(),
        ),
      );
      final offers = MockOfferBloc();
      whenListen(
        offers,
        const Stream<offer.DriverOfferState>.empty(),
        initialState: const offer.DriverOfferState(),
      );
      final presence = MockPresenceBloc();
      whenListen(
        presence,
        const Stream<DriverPresenceState>.empty(),
        initialState: const DriverPresenceState(),
      );
      getIt
        ..registerFactory<offer.DriverOfferBloc>(() => offers)
        ..registerFactory<DriverPresenceBloc>(() => presence);
      final rides = MockRides();
      final earnings = MockEarnings();
      when(
        () => rides.watchRide('ride'),
      ).thenAnswer((_) => Stream.value(Right(historyRide('ride'))));
      when(
        () => rides.history(party: RideParty.driver, uid: 'u'),
      ).thenAnswer((_) async => Right(RideHistoryPage(items: [])));
      when(() => earnings.week('u', any())).thenAnswer((invocation) async {
        final day = invocation.positionalArguments[1] as DateTime;
        return Right(
          List.generate(
            7,
            (i) => DailyEarnings(day: day.subtract(Duration(days: 6 - i))),
          ),
        );
      });
      when(
        () => earnings.watchDay('u', any()),
      ).thenAnswer((_) => const Stream.empty());
      getIt
        ..registerFactory<RideReceiptCubit>(
          () => RideReceiptCubit(WatchRide(rides)),
        )
        ..registerFactory<EarningsScreenCubit>(
          () => EarningsScreenCubit(
            GetWeekEarnings(earnings),
            WatchDayEarnings(earnings),
            GetRideHistory(rides),
          ),
        );
      final refresh = SessionRouterRefresh(session.stream);
      final router = createAppRouter(session, refresh)..go(path);
      await tester.pumpWidget(historyWrap(const SizedBox(), router: router));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, path);
      expect(
        find.byType(
          path.contains('earnings') ? DriverEarningsScreen : RideReceiptScreen,
        ),
        findsOneWidget,
      );
      verify(() => presence.add(any(that: isA<Started>()))).called(1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      refresh.dispose();
      await getIt.reset();
    });
  }
}
