import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/submit_driver_application.dart';
import 'package:mishwar/features/common/user/domain/usecases/upload_license_photo.dart';
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockDrivers extends Mock implements DriverRepository {}

const vehicle = VehicleEntity(
  type: VehicleType.economy,
  make: 'Toyota',
  model: 'Corolla',
  color: 'White',
  plate: '12-34567',
);
void main() {
  late MockDrivers repository;
  final bytes = Uint8List.fromList([1, 2, 3]);
  DriverOnboardingCubit build() => DriverOnboardingCubit(
    UploadLicensePhoto(repository),
    SubmitDriverApplication(repository),
  );
  void fill(DriverOnboardingCubit cubit, {String plate = '12-34567'}) {
    cubit
      ..change('make', ' Toyota ')
      ..change('model', 'Corolla')
      ..change('color', 'White')
      ..change('plate', plate)
      ..photoSelected(bytes, 'image/jpeg');
  }

  setUpAll(() {
    registerFallbackValue(vehicle);
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    repository = MockDrivers();
    when(
      () => repository.uploadLicensePhoto('u', any(), any()),
    ).thenAnswer((_) async => const Right('drivers/u/license'));
    when(
      () => repository.submitApplication('u', any(), any()),
    ).thenAnswer((_) async => const Right(unit));
  });
  blocTest<DriverOnboardingCubit, DriverOnboardingState>(
    'empty submission exposes every field error without uploading',
    build: build,
    act: (cubit) => cubit.submit('u'),
    expect: () => [
      isA<DriverOnboardingState>()
          .having(
            (s) => s.errors.keys,
            'fields',
            unorderedEquals(['make', 'model', 'color', 'plate', 'photo']),
          )
          .having((s) => s.attempted, 'attempted', true),
    ],
    verify: (_) =>
        verifyNever(() => repository.uploadLicensePhoto(any(), any(), any())),
  );
  for (final field in ['make', 'model', 'color']) {
    for (final value in ['a', List.filled(31, 'a').join()]) {
      blocTest<DriverOnboardingCubit, DriverOnboardingState>(
        'validates $field length ${value.length}',
        build: build,
        seed: () => DriverOnboardingState(photo: bytes),
        act: (cubit) async {
          fill(cubit);
          cubit.change(field, value);
          await cubit.submit('u');
        },
        verify: (cubit) {
          expect(cubit.state.errors[field], ValidationFailure(field, 'length'));
          verifyNever(() => repository.uploadLicensePhoto(any(), any(), any()));
        },
      );
    }
  }
  blocTest<DriverOnboardingCubit, DriverOnboardingState>(
    'invalid plate is a field error',
    build: build,
    act: (cubit) async {
      fill(cubit, plate: '1234');
      await cubit.submit('u');
    },
    verify: (cubit) => expect(
      cubit.state.errors['plate'],
      const ValidationFailure('plate', 'format'),
    ),
  );
  blocTest<DriverOnboardingCubit, DriverOnboardingState>(
    'uploads before submit and normalizes Arabic plate digits',
    build: build,
    act: (cubit) async {
      fill(cubit, plate: ' ١٢-٣٤٥٦٧ ');
      await cubit.submit('u');
    },
    verify: (cubit) {
      expect(cubit.state.succeeded, true);
      verifyInOrder([
        () => repository.uploadLicensePhoto('u', bytes, 'image/jpeg'),
        () => repository.submitApplication('u', vehicle, 'drivers/u/license'),
      ]);
    },
  );
  blocTest<DriverOnboardingCubit, DriverOnboardingState>(
    'upload failure stops application submission',
    build: () {
      when(
        () => repository.uploadLicensePhoto('u', any(), any()),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      return build();
    },
    act: (cubit) async {
      fill(cubit);
      await cubit.submit('u');
    },
    verify: (cubit) {
      expect(cubit.state.failure, const NetworkFailure('offline'));
      expect(cubit.state.isLoading, false);
      verifyNever(() => repository.submitApplication(any(), any(), any()));
    },
  );
  blocTest<DriverOnboardingCubit, DriverOnboardingState>(
    'rejected application prefill reuses its saved photo',
    build: build,
    act: (cubit) async {
      cubit.prefill(
        const DriverEntity(
          id: 'u',
          status: DriverStatus.rejected,
          isOnline: false,
          vehicle: vehicle,
          licensePhotoPath: 'drivers/u/existing',
        ),
      );
      await cubit.submit('u');
    },
    verify: (cubit) {
      expect(cubit.state.succeeded, true);
      verifyNever(() => repository.uploadLicensePhoto(any(), any(), any()));
      verify(
        () => repository.submitApplication('u', vehicle, 'drivers/u/existing'),
      ).called(1);
    },
  );
  test('use case validates even when called without the form', () async {
    final submit = SubmitDriverApplication(repository);
    expect(
      await submit('u', vehicle, ''),
      const Left<Failure, Unit>(ValidationFailure('photo', 'required')),
    );
    verifyNever(() => repository.submitApplication(any(), any(), any()));
  });
}
