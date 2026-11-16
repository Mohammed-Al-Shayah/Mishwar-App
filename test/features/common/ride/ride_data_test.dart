import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';
import '../../rider/confirm/ride_confirm_cubit_test.dart' show draft;

class MockSource extends Mock implements RideRemoteDataSource {}

Map<String, dynamic> rideJson() => {
  'id': 'ride',
  'riderId': 'rider',
  'driverId': null,
  'status': 'searching',
  'vehicleType': 'economy',
  'pickup': {
    'name': 'Pickup',
    'address': 'Start',
    'geopoint': const GeoPoint(31.95, 35.91),
  },
  'dropoff': {
    'name': 'Dropoff',
    'address': 'End',
    'geopoint': const GeoPoint(32, 36),
  },
  'route': {'polyline': 'abc', 'distanceMeters': 5000, 'durationSeconds': 600},
  'fare': {'estimated': 2.55, 'final': null, 'currency': 'JOD'},
  'createdAt': Timestamp.fromDate(DateTime.utc(2026)),
  'searchExpiresAt': Timestamp.fromDate(
    DateTime.utc(2026).add(const Duration(minutes: 2)),
  ),
};
void main() {
  test(
    'Firestore ride round-trip preserves nested data, timestamps and fils',
    () {
      final model = RideModel.fromJson(rideJson());
      expect(RideModel.fromJson(model.toJson()), model);
      final entity = model.toEntity();
      expect(entity.fareEstimatedFils, 2550);
      expect(entity.fareFinalFils, isNull);
      expect(entity.pickup.location.lat, 31.95);
      expect(entity.route!.durationSeconds, 600);
      expect(entity.createdAt.isUtc, isTrue);
      expect(
        entity.searchExpiresAt!.difference(entity.createdAt),
        const Duration(minutes: 2),
      );
      for (final status in ['in_progress', 'no_drivers', 'cancelled']) {
        final changed = RideModel.fromJson({
          ...rideJson(),
          'status': status,
          'fare': {'estimated': 2.55, 'final': 3.2, 'currency': 'JOD'},
        });
        expect(changed.toJson()['status'], status);
        expect(changed.toEntity().fareFinalFils, 3200);
      }
    },
  );
  test('optional route and search deadline are supported', () {
    final model = RideModel.fromJson({
      ...rideJson(),
      'route': null,
      'searchExpiresAt': null,
    });
    expect(model.toEntity().route, isNull);
    expect(model.toEntity().searchExpiresAt, isNull);
  });
  test('request sends places and selected type without client price', () async {
    final source = MockSource();
    when(() => source.request(any())).thenAnswer((_) async => 'ride');
    final result = await RideRepositoryImpl(
      source,
    ).requestRide(draft, VehicleType.van);
    expect(result, const Right<Failure, String>('ride'));
    final data =
        verify(() => source.request(captureAny())).captured.single as Map;
    expect(data['vehicleType'], 'van');
    expect(data['fare'], isNull);
    expect((data['pickup'] as Map)['lat'], draft.pickup.location.lat);
  });
  test(
    'active ride details become a typed failure; network errors stay mapped',
    () async {
      final source = MockSource();
      final repository = RideRepositoryImpl(source);
      when(() => source.request(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'Active ride',
          details: const {'activeRideId': 'existing'},
        ),
      );
      expect(
        await repository.requestRide(draft, VehicleType.economy),
        const Left<Failure, String>(ActiveRideFailure('existing')),
      );
      when(
        () => source.request(any()),
      ).thenThrow(
        FirebaseFunctionsException(code: 'unavailable', message: 'Offline'),
      );
      expect(
        (await repository.requestRide(
          draft,
          VehicleType.economy,
        )).getLeft().toNullable(),
        isA<NetworkFailure>(),
      );
    },
  );
  test(
    'watch streams map snapshots and surface errors; cancel calls the function',
    () async {
      final source = MockSource();
      final repository = RideRepositoryImpl(source);
      when(
        () => source.watch('ride'),
      ).thenAnswer((_) => Stream.value(RideModel.fromJson(rideJson())));
      expect(
        (await repository.watchRide('ride').first)
            .getRight()
            .toNullable()!
            .status,
        RideStatus.searching,
      );
      when(
        () => source.active('rider'),
      ).thenAnswer((_) => Stream.fromIterable(['ride', null]));
      expect(await repository.watchActiveRideId('rider').toList(), [
        const Right<Failure, String?>('ride'),
        const Right<Failure, String?>(null),
      ]);
      when(
        () => source.watch('ride'),
      ).thenAnswer((_) => Stream.error(Exception('offline')));
      expect((await repository.watchRide('ride').first).isLeft(), isTrue);
      when(() => source.cancel('ride')).thenAnswer((_) async {});
      expect(
        await repository.cancelRide('ride'),
        const Right<Failure, Unit>(unit),
      );
      verify(() => source.cancel('ride')).called(1);
    },
  );
}
