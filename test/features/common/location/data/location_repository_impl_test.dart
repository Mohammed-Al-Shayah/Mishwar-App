import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/data/datasources/geolocator_client.dart';
import 'package:mishwar/features/common/location/data/datasources/location_data_source.dart';
import 'package:mishwar/features/common/location/data/repositories/location_repository_impl.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mocktail/mocktail.dart';

class MockGeolocatorClient extends Mock implements GeolocatorClient {}

void main() {
  late MockGeolocatorClient client;
  late LocationRepositoryImpl repository;
  final position = Position(
    longitude: 35.9,
    latitude: 31.9,
    timestamp: DateTime.utc(2026),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  setUp(() {
    client = MockGeolocatorClient();
    repository = LocationRepositoryImpl(LocationDataSource(client));
    when(client.isLocationServiceEnabled).thenAnswer((_) async => true);
  });
  for (final permission in LocationPermission.values) {
    final expected = switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionStatus.granted,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      _ => LocationPermissionStatus.denied,
    };
    test('maps checked and requested $permission', () async {
      when(client.checkPermission).thenAnswer((_) async => permission);
      when(client.requestPermission).thenAnswer((_) async => permission);
      expect(
        await repository.checkPermission(),
        Right<Failure, LocationPermissionStatus>(expected),
      );
      expect(
        await repository.requestPermission(),
        Right<Failure, LocationPermissionStatus>(expected),
      );
    });
  }
  test('service disabled short circuits permission requests', () async {
    when(client.isLocationServiceEnabled).thenAnswer((_) async => false);
    expect(
      await repository.checkPermission(),
      const Right<Failure, LocationPermissionStatus>(
        LocationPermissionStatus.serviceDisabled,
      ),
    );
    expect(
      await repository.requestPermission(),
      const Right<Failure, LocationPermissionStatus>(
        LocationPermissionStatus.serviceDisabled,
      ),
    );
    verifyNever(client.checkPermission);
    verifyNever(client.requestPermission);
  });
  test('maps current and watched positions to domain coordinates', () async {
    when(client.currentPosition).thenAnswer((_) async => position);
    when(client.watchPosition).thenAnswer((_) => Stream.value(position));
    expect(
      await repository.currentPosition(),
      const Right<Failure, GeoPointValue>(GeoPointValue(31.9, 35.9)),
    );
    expect(
      repository.watchPosition(),
      emits(const Right<Failure, GeoPointValue>(GeoPointValue(31.9, 35.9))),
    );
  });
  for (final entry in <Exception, LocationFailureCode>{
    TimeoutException('timeout'): LocationFailureCode.timeout,
    const PermissionDeniedException('denied'):
        LocationFailureCode.permissionDenied,
    const LocationServiceDisabledException():
        LocationFailureCode.serviceDisabled,
    Exception('private details'): LocationFailureCode.unknown,
  }.entries) {
    test('maps current and stream error to ${entry.value}', () async {
      when(client.currentPosition).thenThrow(entry.key);
      when(client.watchPosition).thenAnswer((_) => Stream.error(entry.key));
      expect(
        await repository.currentPosition(),
        Left<Failure, GeoPointValue>(LocationFailure(entry.value)),
      );
      expect(
        repository.watchPosition(),
        emits(Left<Failure, GeoPointValue>(LocationFailure(entry.value))),
      );
    });
  }
  testWidgets('current position times out after ten seconds', (tester) async {
    when(
      client.currentPosition,
    ).thenAnswer((_) => Completer<Position>().future);
    final result = repository.currentPosition();
    await tester.pump(const Duration(seconds: 10));
    expect(
      await result,
      const Left<Failure, GeoPointValue>(
        LocationFailure(LocationFailureCode.timeout),
      ),
    );
  });
  test('settings delegate to platform wrapper', () async {
    when(client.openAppSettings).thenAnswer((_) async => true);
    when(client.openLocationSettings).thenAnswer((_) async => true);
    await repository.openAppSettings();
    await repository.openLocationSettings();
    verify(client.openAppSettings).called(1);
    verify(client.openLocationSettings).called(1);
  });
  test('permission platform errors become failures', () async {
    when(client.isLocationServiceEnabled).thenThrow(Exception('private'));
    expect(
      await repository.checkPermission(),
      const Left<Failure, LocationPermissionStatus>(
        LocationFailure(LocationFailureCode.unknown),
      ),
    );
  });
}
