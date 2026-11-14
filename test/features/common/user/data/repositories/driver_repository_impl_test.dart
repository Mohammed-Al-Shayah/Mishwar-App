import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/data/datasources/driver_remote_data_source.dart';
import 'package:mishwar/features/common/user/data/models/driver_model.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/data/repositories/driver_repository_impl.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSource extends Mock implements DriverRemoteDataSource {}

void main() {
  const vehicle = VehicleEntity(
    type: VehicleType.comfort,
    make: 'Toyota',
    model: 'Corolla',
    color: 'White',
    plate: '12-34567',
  );
  final model = VehicleModel.fromEntity(vehicle);
  final bytes = Uint8List.fromList([1]);
  late MockSource source;
  late DriverRepositoryImpl repository;
  setUp(() {
    source = MockSource();
    repository = DriverRepositoryImpl(source);
  });
  test('upload returns storage path', () async {
    when(
      () => source.uploadLicensePhoto('u', bytes, 'image/jpeg'),
    ).thenAnswer((_) async => 'drivers/u/license');
    expect(
      await repository.uploadLicensePhoto('u', bytes, 'image/jpeg'),
      const Right<Failure, String>('drivers/u/license'),
    );
  });
  for (final code in ['unavailable', 'unauthorized']) {
    test('upload maps $code', () async {
      when(
        () => source.uploadLicensePhoto('u', bytes, 'image/jpeg'),
      ).thenThrow(FirebaseException(plugin: 'firebase_storage', code: code));
      final failure = code == 'unavailable'
          ? const NetworkFailure('unavailable')
          : ServerFailure(code);
      expect(
        await repository.uploadLicensePhoto('u', bytes, 'image/jpeg'),
        Left<Failure, String>(failure),
      );
    });
    test('submit maps $code', () async {
      when(
        () => source.submitApplication('u', model, 'drivers/u/license'),
      ).thenThrow(FirebaseException(plugin: 'cloud_firestore', code: code));
      final failure = code == 'unavailable'
          ? const NetworkFailure('unavailable')
          : ServerFailure(code);
      expect(
        await repository.submitApplication('u', vehicle, 'drivers/u/license'),
        Left<Failure, Unit>(failure),
      );
    });
  }
  test('submit converts vehicle and returns unit', () async {
    when(
      () => source.submitApplication('u', model, 'drivers/u/license'),
    ).thenAnswer((_) async {});
    expect(
      await repository.submitApplication('u', vehicle, 'drivers/u/license'),
      const Right<Failure, Unit>(unit),
    );
    verify(
      () => source.submitApplication('u', model, 'drivers/u/license'),
    ).called(1);
  });
  test('watch maps missing document and driver model', () async {
    final driver = DriverModel(
      id: 'u',
      status: DriverStatus.rejected,
      isOnline: false,
      vehicle: model,
      licensePhotoPath: 'drivers/u/license',
      rejectionReason: 'Blurry',
    );
    when(
      () => source.watchDriver('u'),
    ).thenAnswer((_) => Stream.fromIterable([null, driver]));
    expect(await repository.watchDriver('u').toList(), [
      const Right<Failure, DriverEntity?>(null),
      Right<Failure, DriverEntity?>(driver.toEntity()),
    ]);
  });
  test('watch stream errors map to failure', () async {
    when(() => source.watchDriver('u')).thenAnswer(
      (_) => Stream.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      ),
    );
    expect(await repository.watchDriver('u').toList(), [
      const Left<Failure, DriverEntity?>(NetworkFailure('unavailable')),
    ]);
  });
  test('unexpected upload and submit errors map to server failure', () async {
    when(
      () => source.uploadLicensePhoto('u', bytes, 'image/jpeg'),
    ).thenThrow(StateError('oops'));
    when(
      () => source.submitApplication('u', model, 'drivers/u/license'),
    ).thenThrow(StateError('oops'));
    expect(
      await repository.uploadLicensePhoto('u', bytes, 'image/jpeg'),
      const Left<Failure, String>(ServerFailure('driver-error')),
    );
    expect(
      await repository.submitApplication('u', vehicle, 'drivers/u/license'),
      const Left<Failure, Unit>(ServerFailure('driver-error')),
    );
  });
}
