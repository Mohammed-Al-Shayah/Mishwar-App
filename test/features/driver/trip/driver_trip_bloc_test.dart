import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/update_ride_status.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../common/ride/ride_data_test.dart' show rideJson;

class MockRides extends Mock implements RideRepository {}

class MockTripBloc extends MockBloc<DriverTripEvent, DriverTripState>
    implements DriverTripBloc {}

class FakeTicker extends TripTicker {
  FakeTicker(this.time);
  final DateTime Function() time;
  @override
  DateTime now() => time();
}

final tripEpoch = DateTime.utc(2026);
RideEntity tripRide(RideStatus status) => RideModel.fromJson({
  ...rideJson(),
  'driverId': 'd',
  'status': const RideStatusConverter().toJson(status),
  'riderInfo': {'name': 'Rider', 'phone': '+962791234567', 'rating': 4.9},
  'arrivedAt': Timestamp.fromDate(tripEpoch),
  'startedAt': Timestamp.fromDate(tripEpoch.add(const Duration(minutes: 3))),
  'fare': {
    'estimated': 4.7,
    'final': status == RideStatus.completed ? 5.25 : null,
    'currency': 'JOD',
  },
  'route': {
    'polyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    'distanceMeters': 5000,
    'durationSeconds': 600,
  },
}).toEntity();

void main() {
  setUpAll(() => registerFallbackValue(RideStatus.arriving));
  blocTest<DriverTripBloc, DriverTripState>(
    'accepted automatically sends arriving once',
    build: () {
      final rides = MockRides();
      when(() => rides.watchRide('ride')).thenAnswer(
        (_) => Stream.fromIterable([
          Right(tripRide(RideStatus.accepted)),
          Right(tripRide(RideStatus.accepted)),
          Right(tripRide(RideStatus.arriving)),
        ]),
      );
      when(
        () => rides.updateStatus('ride', RideStatus.arriving),
      ).thenAnswer((_) async => const Right(unit));
      return DriverTripBloc(
        'ride',
        WatchRide(rides),
        UpdateRideStatus(rides),
        CancelRide(rides),
        TripTicker(),
      );
    },
    act: (bloc) => bloc.add(const Started()),
    expect: () => [
      isA<DriverTripState>().having((s) => s.busy, 'busy', false),
      isA<DriverTripState>().having((s) => s.busy, 'busy', true),
      isA<DriverTripState>().having(
        (s) => s.ride?.status,
        'status',
        RideStatus.arriving,
      ),
    ],
  );
  for (final scenario in [
    'arrivingRetry',
    'transitions',
    'tooFar',
    'timer',
    'completed',
    'riderCancel',
    'driverCancel',
    'cancelRace',
    'cancelFailure',
    'doubleTap',
    'streamFailure',
    'close',
  ]) {
    test('trip $scenario with fakeAsync', () {
      fakeAsync((async) {
        final rides = MockRides();
        final updates = StreamController<Either<Failure, RideEntity>>();
        when(() => rides.watchRide('ride')).thenAnswer((_) => updates.stream);
        when(
          () => rides.updateStatus('ride', any()),
        ).thenAnswer((_) async => const Right(unit));
        when(() => rides.cancelRide('ride')).thenAnswer(
          (_) async => const Right(CancelRideResult(redispatched: true)),
        );
        final bloc = DriverTripBloc(
          'ride',
          WatchRide(rides),
          UpdateRideStatus(rides),
          CancelRide(rides),
          FakeTicker(() => tripEpoch.add(async.elapsed)),
        )..add(const Started());
        async.flushMicrotasks();
        void snapshot(RideStatus status) {
          updates.add(Right(tripRide(status)));
          async.flushMicrotasks();
        }

        if (scenario == 'arrivingRetry') {
          when(
            () => rides.updateStatus('ride', RideStatus.arriving),
          ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
          snapshot(RideStatus.accepted);
        } else {
          snapshot(RideStatus.arriving);
        }
        switch (scenario) {
          case 'arrivingRetry':
            expect(bloc.state.failure, isA<NetworkFailure>());
            expect(bloc.state.busy, isFalse);
            snapshot(RideStatus.accepted);
            verify(
              () => rides.updateStatus('ride', RideStatus.arriving),
            ).called(1);
            when(
              () => rides.updateStatus('ride', RideStatus.arriving),
            ).thenAnswer((_) async => const Right(unit));
            bloc.add(const RetryPressed());
            async.flushMicrotasks();
            expect(bloc.state.busy, isTrue);
            snapshot(RideStatus.arriving);
            expect(bloc.state.busy, isFalse);
            expect(bloc.state.failure, isNull);
          case 'transitions':
            for (final step in [
              (const ArrivedPressed(), RideStatus.arrived, TripPhase.waiting),
              (const StartPressed(), RideStatus.inProgress, TripPhase.onTrip),
              (
                const CompletePressed(),
                RideStatus.completed,
                TripPhase.collectCash,
              ),
            ]) {
              bloc.add(step.$1);
              async.flushMicrotasks();
              expect(bloc.state.busy, isTrue);
              verify(() => rides.updateStatus('ride', step.$2)).called(1);
              snapshot(step.$2);
              expect(bloc.state.phase, step.$3);
              expect(bloc.state.busy, isFalse);
            }
            bloc.add(const CashCollectedPressed());
            async.flushMicrotasks();
            expect(bloc.state.phase, TripPhase.done);
          case 'tooFar':
            when(
              () => rides.updateStatus('ride', RideStatus.arrived),
            ).thenAnswer(
              (_) async =>
                  const Left(RideActionFailure(RideActionFailureReason.tooFar)),
            );
            bloc.add(const ArrivedPressed());
            async.flushMicrotasks();
            expect(
              bloc.state.failure,
              const RideActionFailure(RideActionFailureReason.tooFar),
            );
            expect(bloc.state.phase, TripPhase.toPickup);
            expect(bloc.state.busy, isFalse);
          case 'timer':
            snapshot(RideStatus.arrived);
            async
              ..elapse(const Duration(seconds: 133))
              ..flushMicrotasks();
            expect(bloc.state.waitingElapsed, const Duration(seconds: 133));
            snapshot(RideStatus.inProgress);
            expect(async.periodicTimerCount, 0);
          case 'completed':
            snapshot(RideStatus.completed);
            expect(bloc.state.phase, TripPhase.collectCash);
            expect(bloc.state.ride!.fareFinalFils, 5250);
          case 'riderCancel':
            snapshot(RideStatus.cancelled);
            expect(bloc.state.phase, TripPhase.cancelled);
          case 'driverCancel':
            bloc
              ..add(const CancelPressed())
              ..add(const CancelPressed());
            async.flushMicrotasks();
            expect(bloc.state.phase, TripPhase.redispatched);
            verify(() => rides.cancelRide('ride')).called(1);
          case 'cancelRace':
            final response = Completer<Either<Failure, CancelRideResult>>();
            when(
              () => rides.cancelRide('ride'),
            ).thenAnswer((_) => response.future);
            bloc.add(const CancelPressed());
            async.flushMicrotasks();
            snapshot(RideStatus.searching);
            updates.add(const Left(PermissionFailure('revoked')));
            async.flushMicrotasks();
            response.complete(
              const Right(CancelRideResult(redispatched: true)),
            );
            async.flushMicrotasks();
            expect(bloc.state.phase, TripPhase.redispatched);
            expect(bloc.state.failure, isNull);
          case 'cancelFailure':
            when(
              () => rides.cancelRide('ride'),
            ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
            bloc.add(const CancelPressed());
            async.flushMicrotasks();
            expect(bloc.state.phase, TripPhase.toPickup);
            expect(bloc.state.busy, isFalse);
            expect(bloc.state.failure, isA<NetworkFailure>());
          case 'doubleTap':
            final response = Completer<Either<Failure, Unit>>();
            when(
              () => rides.updateStatus('ride', RideStatus.arrived),
            ).thenAnswer((_) => response.future);
            bloc
              ..add(const ArrivedPressed())
              ..add(const ArrivedPressed());
            async.flushMicrotasks();
            response.complete(const Right(unit));
            async.flushMicrotasks();
            bloc.add(const ArrivedPressed());
            async.flushMicrotasks();
            verify(
              () => rides.updateStatus('ride', RideStatus.arrived),
            ).called(1);
            snapshot(RideStatus.arrived);
            expect(bloc.state.busy, isFalse);
          case 'streamFailure':
            updates.addError(StateError('offline'));
            async.flushMicrotasks();
            expect(bloc.state.failure, isA<ServerFailure>());
          case 'close':
            snapshot(RideStatus.arrived);
        }
        unawaited(bloc.close());
        unawaited(updates.close());
        async.flushMicrotasks();
        expect(async.periodicTimerCount, 0);
      });
    });
  }
}
