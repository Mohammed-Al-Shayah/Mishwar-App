import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/promos/domain/validate_promo.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/parcel_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/repositories/parcel_repository.dart';
import 'package:mishwar/features/common/ride/domain/usecases/parcel_usecases.dart';
import 'package:mishwar/features/common/ride/presentation/parcel_tools_cubit.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';
import '../common/ride/ride_data_test.dart' show rideJson;
import '../rider/confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, stubSuccess;

class MockParcels extends Mock implements ParcelRepository {}

class MockLocation extends Mock implements LocationRepository {}

class MockRideSource extends Mock implements RideRemoteDataSource {}

const details = ParcelDetails(
  recipientName: 'Recipient',
  recipientPhone: '+962781234567',
  description: 'Books',
  photoPath: 'parcels/rider/photo.jpg',
);
final parcelDraft = RideDraft(
  pickup: draft.pickup,
  dropoff: draft.dropoff,
  parcel: details,
);

void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));
  test(
    'legacy ride defaults and parcel model preserve public details only',
    () {
      expect(
        RideModel.fromJson(rideJson()).toEntity().serviceType,
        ServiceType.ride,
      );
      final model = RideModel.fromJson({
        ...rideJson(),
        'serviceType': 'parcel',
        'parcel': {
          'recipientName': details.recipientName,
          'recipientPhone': details.recipientPhone,
          'description': details.description,
          'photoPath': details.photoPath,
          'deliveryCodeHash': 'private hash',
          'deliveryCodeSalt': 'salt',
          'codeAttempts': 2,
        },
      });
      expect(model.toEntity().parcel!.codeAttempts, 2);
      expect(
        model.toEntity().draft.withPromo('PROMO').parcel,
        model.toEntity().parcel,
      );
      expect(model.parcel!.toJson().keys, isNot(contains('deliveryCodeHash')));
      expect(RideModel.fromJson(model.toJson()), model);
    },
  );
  test(
    'request and schedule send parcel fields, never code or attempt fields',
    () async {
      final source = MockRideSource();
      final repo = RideRepositoryImpl(source);
      when(() => source.request(any())).thenAnswer((_) async => 'id');
      when(() => source.schedule(any())).thenAnswer((_) async => 'scheduled');
      await repo.requestRide(parcelDraft, VehicleType.economy);
      await repo.scheduleRide(parcelDraft, VehicleType.economy);
      final request =
          verify(() => source.request(captureAny())).captured.single as Map;
      final scheduled =
          verify(() => source.schedule(captureAny())).captured.single as Map;
      for (final data in [request, scheduled]) {
        expect(data['serviceType'], 'parcel');
        expect(data['parcel'], {
          'recipientName': 'Recipient',
          'recipientPhone': '+962781234567',
          'description': 'Books',
          'photoPath': 'parcels/rider/photo.jpg',
        });
      }
    },
  );
  for (final reason in ['bad-code', 'code-locked']) {
    test(
      'delivery code forwarded and $reason mapped to typed failure',
      () async {
        final source = MockRideSource();
        final repo = RideRepositoryImpl(source);
        when(
          () => source.updateStatus('id', 'completed', deliveryCode: '4821'),
        ).thenThrow(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'Rejected',
            details: {'reason': reason},
          ),
        );
        final result = await repo.updateStatus(
          'id',
          RideStatus.completed,
          deliveryCode: '4821',
        );
        expect(
          result.getLeft().toNullable(),
          RideActionFailure(
            reason == 'bad-code'
                ? RideActionFailureReason.badCode
                : RideActionFailureReason.codeLocked,
          ),
        );
      },
    );
  }
  test(
    'form validates lengths and normalizes national Jordanian phone',
    () async {
      final cubit = ParcelFormCubit(
        UploadParcelPhoto(MockParcels()),
        CurrentPosition(MockLocation()),
      );
      addTearDown(cubit.close);
      for (final input in [
        ('', '0781234567', 'Books'),
        ('a' * 41, '0781234567', 'Books'),
        ('Name', '+962781234567', 'Books'),
        ('Name', '0781234567', ''),
        ('Name', '0781234567', 'a' * 201),
      ]) {
        expect(cubit.validate(input.$1, input.$2, input.$3), isNull);
        expect(cubit.state.invalid, isTrue);
      }
      expect(
        cubit.validate(' Recipient ', '0781234567', ' Books ')!.recipientPhone,
        details.recipientPhone,
      );
    },
  );
  blocTest<ParcelFormCubit, ParcelFormState>(
    'upload progress and completion are exposed to form',
    build: () {
      final repo = MockParcels();
      when(() => repo.upload('rider', any())).thenAnswer(
        (_) => Stream.fromIterable([
          const Right(ParcelUpload(.5)),
          const Right(ParcelUpload(1, path: 'parcels/rider/photo.jpg')),
        ]),
      );
      return ParcelFormCubit(
        UploadParcelPhoto(repo),
        CurrentPosition(MockLocation()),
      );
    },
    act: (cubit) => cubit.upload('rider', Uint8List(1)),
    expect: () => [
      const ParcelFormState(busy: true, progress: 0),
      const ParcelFormState(busy: true, progress: .5),
      const ParcelFormState(progress: 1, photoPath: 'parcels/rider/photo.jpg'),
    ],
  );
  test('form surfaces location failure and retries successfully', () async {
    final location = MockLocation();
    when(location.currentPosition).thenAnswer(
      (_) async => const Left(LocationFailure(LocationFailureCode.timeout)),
    );
    final cubit = ParcelFormCubit(
      UploadParcelPhoto(MockParcels()),
      CurrentPosition(location),
    );
    addTearDown(cubit.close);
    expect(await cubit.pickup(), isNull);
    expect(cubit.state.busy, isFalse);
    expect(cubit.state.failure, isA<LocationFailure>());
    when(
      location.currentPosition,
    ).thenAnswer((_) async => const Right(GeoPointValue(31.95, 35.91)));
    expect(await cubit.pickup(), const GeoPointValue(31.95, 35.91));
    expect(cubit.state.failure, isNull);
  });
  test(
    'parcel confirmation offers economy only',
    () async {
      final routes = MockRouteRepository();
      stubSuccess(routes);
      final cubit = RideConfirmCubit(
        GetFareEstimates(routes),
        requestRideStub(),
        parcelDraft,
        scheduleRide: scheduleRideStub(),
        validatePromo: ValidatePromo(MockPromoRepository()),
      );
      addTearDown(cubit.close);
      await cubit.start();
      cubit.select(VehicleType.van);
      final loaded = cubit.state as RideConfirmLoaded;
      expect(loaded.fares.map((f) => f.vehicleType), [VehicleType.economy]);
      expect(loaded.selected, VehicleType.economy);
    },
  );
  blocTest<ParcelToolsCubit, ParcelToolsState>(
    'rider code stream and signed photo failure are recoverable',
    build: () {
      final repo = MockParcels();
      when(
        () => repo.watchCode('id'),
      ).thenAnswer((_) => Stream.value(const Right('4821')));
      when(
        () => repo.photoUrl('id'),
      ).thenAnswer((_) async => const Left(ServerFailure('photo')));
      return ParcelToolsCubit(WatchDeliveryCode(repo), GetParcelPhotoUrl(repo));
    },
    act: (cubit) async {
      cubit.watch('id');
      await Future<void>.delayed(Duration.zero);
      await cubit.photo('id');
    },
    expect: () => [
      const ParcelToolsState(code: '4821'),
      const ParcelToolsState(busy: true),
      const ParcelToolsState(failure: ServerFailure('photo')),
    ],
  );
}
