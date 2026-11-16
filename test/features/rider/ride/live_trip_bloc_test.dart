import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_clock.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/ride_mocks.dart';
import '../../common/ride/ride_data_test.dart' show rideJson;

class FakeClock extends RideTrackingClock {
  FakeClock(this.fake);
  final FakeAsync fake;
  @override
  DateTime now() => fake.getClock(DateTime.utc(2026)).now();
}

void main() {
  test('live ETA, arrival, elapsed trip, redispatch notice and completion', () {
    fakeAsync((fake) {
      final repository = MockRideRepository();
      final rides = StreamController<Either<Failure, RideEntity>>();
      final fixes =
          StreamController<Either<Failure, DriverLiveLocation>>.broadcast();
      when(() => repository.watchRide('ride')).thenAnswer((_) => rides.stream);
      when(
        () => repository.watchDriverLocation('ride'),
      ).thenAnswer((_) => fixes.stream);
      final clock = FakeClock(fake);
      final bloc = RideTrackingBloc(
        WatchRide(repository),
        CancelRide(repository),
        'ride',
        WatchDriverLocation(repository),
        clock,
      );
      final base = RideModel.fromJson(rideJson()).copyWith(
        driverId: 'driver',
        acceptedAt: clock.now(),
        arrivedAt: clock.now(),
        startedAt: clock.now(),
      );
      void phase(RideStatus status) {
        rides.add(Right(base.copyWith(status: status).toEntity()));
        fake.flushMicrotasks();
      }

      bloc.add(const RideTrackingStarted());
      fake.flushMicrotasks();
      phase(RideStatus.accepted);
      expect(fixes.hasListener, isTrue);
      fixes.add(
        Right(
          DriverLiveLocation(
            point: const GeoPointValue(32, 36),
            updatedAt: clock.now().subtract(const Duration(seconds: 5)),
          ),
        ),
      );
      fake.flushMicrotasks();
      expect(bloc.state.driverLocation, isNull);
      fixes.add(
        Right(
          DriverLiveLocation(
            point: const GeoPointValue(31.954, 35.91),
            heading: 350,
            updatedAt: clock.now(),
          ),
        ),
      );
      fake.flushMicrotasks();
      expect(bloc.state.etaMinutes, 2);
      expect(bloc.state.driverLocation!.heading, 350);
      phase(RideStatus.arrived);
      expect(bloc.state.waitingSince, clock.now());
      phase(RideStatus.inProgress);
      expect(bloc.state.etaMinutes, 10);
      fake
        ..elapse(const Duration(minutes: 2))
        ..flushMicrotasks();
      expect(bloc.state.etaMinutes, 8);
      phase(RideStatus.searching);
      expect(bloc.state.redispatchNotice, isTrue);
      expect(bloc.state.driverLocation, isNull);
      expect(fixes.hasListener, isFalse);
      fake
        ..elapse(const Duration(seconds: 3))
        ..flushMicrotasks();
      bloc.add(const RideSubtitleTicked());
      fake.flushMicrotasks();
      expect(bloc.state.redispatchNotice, isTrue);
      fake
        ..elapse(const Duration(seconds: 1))
        ..flushMicrotasks();
      expect(bloc.state.redispatchNotice, isFalse);
      phase(RideStatus.accepted);
      phase(RideStatus.completed);
      expect(bloc.state.navigation, RideNavigation.summary);
      expect(fixes.hasListener, isFalse);
      unawaited(bloc.close());
      unawaited(rides.close());
      unawaited(fixes.close());
      fake.flushMicrotasks();
      expect(fake.periodicTimerCount, 0);
    });
  });
}
