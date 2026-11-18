import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancellation_quote.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_clock.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';
import '../../common/ride/ride_data_test.dart' show rideJson;

RideEntity rideWith(RideStatus status) =>
    RideModel.fromJson(rideJson()).toEntityWithStatus(status);

extension on RideModel {
  RideEntity toEntityWithStatus(RideStatus status) =>
      copyWith(status: status).toEntity();
}

void main() {
  late MockRideRepository repository;
  late StreamController<Either<Failure, RideEntity>> updates;
  setUp(() {
    repository = MockRideRepository();
    when(
      () => repository.watchDriverLocation(any()),
    ).thenAnswer((_) => const Stream.empty());
    updates = StreamController.broadcast();
    when(() => repository.watchRide('ride')).thenAnswer((_) => updates.stream);
    when(
      () => repository.cancelRide('ride'),
    ).thenAnswer((_) async => const Right(CancelRideResult()));
  });
  tearDown(() => updates.close());
  RideTrackingBloc build() => RideTrackingBloc(
    WatchRide(repository),
    CancelRide(repository),
    'ride',
    WatchDriverLocation(repository),
    RideTrackingClock(),
    CancellationQuote(repository),
  );
  blocTest<RideTrackingBloc, RideTrackingState>(
    'searching to no drivers and retry retains draft',
    build: build,
    act: (bloc) async {
      bloc.add(const RideTrackingStarted());
      await Future<void>.delayed(Duration.zero);
      updates.add(Right(rideWith(RideStatus.searching)));
      await Future<void>.delayed(Duration.zero);
      updates.add(Right(rideWith(RideStatus.noDrivers)));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RideRetryRequested());
    },
    expect: () => [
      isA<RideTrackingState>().having(
        (s) => s.ride!.status,
        'status',
        RideStatus.searching,
      ),
      isA<RideTrackingState>().having(
        (s) => s.ride!.status,
        'status',
        RideStatus.noDrivers,
      ),
      isA<RideTrackingState>()
          .having((s) => s.navigation, 'nav', RideNavigation.confirm)
          .having(
            (s) => s.retryDraft,
            'draft',
            rideWith(RideStatus.searching).draft,
          ),
    ],
  );
  blocTest<RideTrackingBloc, RideTrackingState>(
    'cancelled snapshot navigates home',
    build: build,
    act: (bloc) async {
      bloc.add(const RideTrackingStarted());
      await Future<void>.delayed(Duration.zero);
      updates.add(Right(rideWith(RideStatus.cancelled)));
    },
    expect: () => [
      isA<RideTrackingState>().having(
        (s) => s.navigation,
        'nav',
        RideNavigation.home,
      ),
    ],
  );
  blocTest<RideTrackingBloc, RideTrackingState>(
    'arriving cancellation waits for authoritative snapshot',
    build: build,
    seed: () => RideTrackingState(ride: rideWith(RideStatus.arriving)),
    act: (bloc) => bloc.add(const RideCancelRequested()),
    expect: () => [
      isA<RideTrackingState>().having((s) => s.isCancelling, 'busy', true),
      isA<RideTrackingState>()
          .having((s) => s.isCancelling, 'busy', false)
          .having((s) => s.navigation, 'nav', null),
    ],
    verify: (_) => verify(() => repository.cancelRide('ride')).called(1),
  );
  blocTest<RideTrackingBloc, RideTrackingState>(
    'cancel failure leaves ride and shows error',
    build: () {
      when(
        () => repository.cancelRide('ride'),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      return build();
    },
    seed: () => RideTrackingState(ride: rideWith(RideStatus.searching)),
    act: (bloc) => bloc.add(const RideCancelRequested()),
    expect: () => [
      isA<RideTrackingState>().having((s) => s.isCancelling, 'busy', true),
      isA<RideTrackingState>().having(
        (s) => s.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    ],
  );
}
