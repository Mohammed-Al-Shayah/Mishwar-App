import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_state.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/location_mocks.dart';

void main() {
  late MockLocationRepository repository;
  const point = GeoPointValue(31.9, 35.9);
  const second = GeoPointValue(32, 36);
  const locating = RiderHomeState(isLocating: true);
  const granted = RiderHomeState(
    permission: LocationPermissionStatus.granted,
    isLocating: true,
  );
  setUp(() {
    repository = MockLocationRepository();
    when(
      repository.checkPermission,
    ).thenAnswer((_) async => const Right(LocationPermissionStatus.granted));
    when(
      repository.currentPosition,
    ).thenAnswer((_) async => const Right(point));
    when(repository.watchPosition).thenAnswer((_) => const Stream.empty());
  });
  blocTest<RiderHomeCubit, RiderHomeState>(
    'granted: initial fix then live updates',
    build: () {
      when(
        repository.watchPosition,
      ).thenAnswer((_) => Stream.value(const Right(second)));
      return riderCubit(repository);
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      locating,
      granted,
      const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        position: point,
      ),
      const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        position: second,
      ),
    ],
    verify: (_) => verifyNever(repository.requestPermission),
  );
  blocTest<RiderHomeCubit, RiderHomeState>(
    'denied requests and becomes granted',
    build: () {
      when(
        repository.checkPermission,
      ).thenAnswer((_) async => const Right(LocationPermissionStatus.denied));
      when(
        repository.requestPermission,
      ).thenAnswer((_) async => const Right(LocationPermissionStatus.granted));
      return riderCubit(repository);
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      locating,
      granted,
      const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        position: point,
      ),
    ],
    verify: (_) => verify(repository.requestPermission).called(1),
  );
  for (final status in [
    LocationPermissionStatus.denied,
    LocationPermissionStatus.deniedForever,
    LocationPermissionStatus.serviceDisabled,
  ]) {
    blocTest<RiderHomeCubit, RiderHomeState>(
      'permission $status stops location',
      build: () {
        when(repository.checkPermission).thenAnswer((_) async => Right(status));
        when(
          repository.requestPermission,
        ).thenAnswer((_) async => Right(status));
        return riderCubit(repository);
      },
      act: (cubit) => cubit.start(),
      expect: () => [locating, RiderHomeState(permission: status)],
      verify: (_) {
        verifyNever(repository.currentPosition);
        verifyNever(repository.watchPosition);
        if (status != LocationPermissionStatus.denied) {
          verifyNever(repository.requestPermission);
        }
      },
    );
  }
  blocTest<RiderHomeCubit, RiderHomeState>(
    'timeout failure still watches for a fix',
    build: () {
      when(repository.currentPosition).thenAnswer(
        (_) async => const Left(LocationFailure(LocationFailureCode.timeout)),
      );
      when(
        repository.watchPosition,
      ).thenAnswer((_) => Stream.value(const Right(point)));
      return riderCubit(repository);
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      locating,
      granted,
      const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        failure: LocationFailure(LocationFailureCode.timeout),
      ),
      const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        position: point,
      ),
    ],
  );
  test('close cancels watch and ignores a pending fix', () async {
    var cancelled = false;
    final stream = StreamController<Either<Failure, GeoPointValue>>(
      onCancel: () => cancelled = true,
    );
    when(repository.watchPosition).thenAnswer((_) => stream.stream);
    final cubit = riderCubit(repository);
    await cubit.start();
    await cubit.close();
    expect(cancelled, isTrue);
    await stream.close();
    final pending = Completer<Either<Failure, GeoPointValue>>();
    when(repository.currentPosition).thenAnswer((_) => pending.future);
    final other = riderCubit(repository);
    final start = other.start();
    await Future<void>.delayed(Duration.zero);
    await other.close();
    pending.complete(const Right(point));
    await start;
  });
  test('settings actions use the correct use case', () async {
    when(repository.openAppSettings).thenAnswer((_) async {});
    when(repository.openLocationSettings).thenAnswer((_) async {});
    final cubit = riderCubit(repository);
    await cubit.openAppSettings();
    await cubit.openLocationSettings();
    verify(repository.openAppSettings).called(1);
    verify(repository.openLocationSettings).called(1);
    await cubit.close();
  });
}
