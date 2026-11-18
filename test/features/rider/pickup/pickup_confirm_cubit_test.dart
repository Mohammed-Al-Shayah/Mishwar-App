import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/pickup/domain/pickup_repository.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockPickupRepository extends Mock implements PickupRepository {}

class MockPosition extends Mock implements CurrentPosition {}

const point = GeoPointValue(31.9, 35.9);
const initial = RideStop(name: 'Initial', address: 'Address', location: point);
const suggestion = PickupSuggestion(
  id: 'parking',
  name: 'Parking',
  location: GeoPointValue(31.92, 35.9),
  distanceMeters: 2224,
);

PickupConfirmCubit pickupCubit(
  MockPickupRepository repository, {
  RideStop stop = initial,
}) {
  final position = MockPosition();
  when(position.call).thenAnswer((_) async => const Right(point));
  when(
    () => repository.suggestions(any()),
  ).thenAnswer((_) async => const Right([suggestion]));
  return PickupConfirmCubit(
    ReverseGeocode(repository),
    GetPickupSuggestions(repository),
    position,
    stop,
  );
}

void main() {
  setUp(() => registerFallbackValue(point));
  test('debounces idle for 400 ms; moving ? resolving ? resolved', () {
    fakeAsync((async) {
      final repository = MockPickupRepository();
      final pending = Completer<Either<Failure, RideStop>>();
      when(
        () => repository.reverse(any(), 'ar'),
      ).thenAnswer((_) => pending.future);
      final cubit = pickupCubit(repository);
      unawaited(cubit.start(lang: 'ar', fallback: 'Pickup point'));
      async.flushMicrotasks();
      expect(cubit.state.suggestions, [suggestion]);
      cubit
        ..moving()
        ..cameraMoved(suggestion.location)
        ..cameraIdle();
      async.elapse(const Duration(milliseconds: 399));
      expect(cubit.state.phase, PickupPhase.moving);
      verifyNever(() => repository.reverse(any(), any()));
      cubit.cameraIdle();
      async.elapse(const Duration(milliseconds: 399));
      verifyNever(() => repository.reverse(any(), any()));
      async.elapse(const Duration(milliseconds: 1));
      expect(cubit.state.phase, PickupPhase.resolving);
      pending.complete(
        const Right(
          RideStop(
            name: 'Resolved',
            address: 'Street',
            location: GeoPointValue(31.92, 35.9),
          ),
        ),
      );
      async.flushMicrotasks();
      expect(cubit.state.phase, PickupPhase.resolved);
      expect(cubit.state.stop.name, 'Resolved');
      expect(cubit.state.farFromDevice, isTrue);
      unawaited(cubit.close());
    });
  });
  test(
    'suggestion selection preserves coordinates on failure with generic label',
    () {
      fakeAsync((async) {
        final repository = MockPickupRepository();
        when(
          () => repository.reverse(any(), 'en'),
        ).thenAnswer((_) async => const Left(ServerFailure('private')));
        final cubit = pickupCubit(repository);
        unawaited(cubit.start(lang: 'en', fallback: 'Pickup point'));
        async.flushMicrotasks();
        expect(cubit.state.farFromDevice, isFalse);
        cubit.select(suggestion);
        expect(cubit.state.stop.location, suggestion.location);
        expect(cubit.state.phase, PickupPhase.moving);
        async
          ..elapse(const Duration(milliseconds: 400))
          ..flushMicrotasks();
        expect(cubit.state.phase, PickupPhase.failure);
        expect(cubit.state.stop.location, suggestion.location);
        expect(cubit.state.stop.name, 'Pickup point');
        expect(cubit.state.farFromDevice, isTrue);
        unawaited(cubit.close());
      });
    },
  );
  test(
    'new movement discards in-flight response and close cancels debounce',
    () {
      fakeAsync((async) {
        final repository = MockPickupRepository();
        final pending = Completer<Either<Failure, RideStop>>();
        when(
          () => repository.reverse(any(), 'ar'),
        ).thenAnswer((_) => pending.future);
        final cubit = pickupCubit(repository);
        unawaited(cubit.start(lang: 'ar', fallback: 'Pickup point'));
        async.elapse(const Duration(milliseconds: 400));
        cubit
          ..moving()
          ..cameraMoved(suggestion.location);
        pending.complete(const Right(initial));
        async.flushMicrotasks();
        expect(cubit.state.phase, PickupPhase.moving);
        expect(cubit.state.stop.location, suggestion.location);
        cubit.cameraIdle();
        unawaited(cubit.close());
        async.elapse(const Duration(seconds: 1));
        verify(() => repository.reverse(any(), 'ar')).called(1);
      });
    },
  );
}
