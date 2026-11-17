import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Right;
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/update_ride_status.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart'
    as trip;
import 'package:mishwar/features/driver/trip/presentation/driver_trip_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/driver/offer/driver_offer_bloc_test.dart'
    show MockOfferBloc;
import '../../features/driver/offer/driver_offer_bloc_test.dart' show MockRides;
import '../../features/driver/presence/driver_home_screen_test.dart'
    show MockPresenceBloc, map, size, wrap;
import '../../features/driver/presence/driver_home_screen_test.dart'
    show homeEarnings;
import '../../features/driver/presence/driver_presence_bloc_test.dart'
    show driver;
import '../../features/driver/trip/driver_trip_bloc_test.dart' show tripRide;

class MockSession extends MockCubit<SessionState> implements SessionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GoOnlinePressed());
    registerFallbackValue(const offer.Started('d'));
  });
  for (final currentRide in [null, 'ride']) {
    testWidgets('approved driver home restores ride=$currentRide', (
      tester,
    ) async {
      size(tester);
      getIt.registerFactory<DriverEarningsCubit>(homeEarnings);
      addTearDown(() => getIt.unregister<DriverEarningsCubit>());
      final session = MockSession();
      final bloc = MockPresenceBloc();
      whenListen(
        session,
        const Stream<SessionState>.empty(),
        initialState: SessionReady(
          UserEntity(
            id: 'd',
            name: 'Driver',
            phone: '+962791234567',
            createdAt: DateTime.utc(2026),
            role: UserRole.driver,
          ),
          driver: driver(ride: currentRide),
        ),
      );
      whenListen(
        bloc,
        const Stream<DriverPresenceState>.empty(),
        initialState: const DriverPresenceState(),
      );
      final offerBloc = MockOfferBloc();
      whenListen(
        offerBloc,
        const Stream<offer.DriverOfferState>.empty(),
        initialState: const offer.DriverOfferState(),
      );
      var offerCreations = 0;
      getIt.registerFactory<offer.DriverOfferBloc>(() {
        offerCreations++;
        return offerBloc;
      });
      addTearDown(() => getIt.unregister<offer.DriverOfferBloc>());
      var presenceCreations = 0;
      getIt.registerFactory<DriverPresenceBloc>(() {
        presenceCreations++;
        return bloc;
      });
      addTearDown(() => getIt.unregister<DriverPresenceBloc>());
      final rides = MockRides();
      when(
        () => rides.watchRide('ride'),
      ).thenAnswer((_) => Stream.value(Right(tripRide(RideStatus.arriving))));
      getIt.registerLazySingleton<WatchRide>(() => WatchRide(rides));
      addTearDown(() => getIt.unregister<WatchRide>());
      getIt.registerFactoryParam<trip.DriverTripBloc, String, dynamic>(
        (id, _) => trip.DriverTripBloc(
          id,
          WatchRide(rides),
          UpdateRideStatus(rides),
          CancelRide(rides),
          trip.TripTicker(),
        ),
      );
      addTearDown(() => getIt.unregister<trip.DriverTripBloc>());
      final refresh = SessionRouterRefresh(session.stream);
      addTearDown(refresh.dispose);
      final router = createAppRouter(session, refresh, driverMapBuilder: map);
      addTearDown(router.dispose);
      // The shared wrapper provides localization and ScreenUtil to the router.
      await tester.pumpWidget(
        wrap(
          Router(
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        currentRide == null ? '/driver' : '/driver/ride/ride',
      );
      if (currentRide != null) {
        expect(find.byType(DriverTripScreen), findsOneWidget);
        expect(find.text('Pickup'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      }
      if (currentRide == null) {
        expect(find.byType(DriverHomeScreen), findsOneWidget);
      }
      verify(() => bloc.add(any(that: isA<Started>()))).called(1);
      if (currentRide == null) {
        router.go('/driver/ride/ride');
        await tester.pumpAndSettle();
        expect(find.byType(DriverTripScreen), findsOneWidget);
        verifyNever(bloc.close);
        router.go('/driver');
        await tester.pumpAndSettle();
        expect(find.byType(DriverHomeScreen), findsOneWidget);
        verifyNever(() => bloc.add(any(that: isA<Started>())));
      }
      expect(presenceCreations, 1);
      expect(offerCreations, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
