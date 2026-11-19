import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
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
  'offerExpiresAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 0, 0, 15)),
  'offerDistanceMeters': 1200,
  'searchExpiresAt': Timestamp.fromDate(
    DateTime.utc(2026).add(const Duration(minutes: 2)),
  ),
};
void main() {
  test(
    'promo data maps server discount and applied flag with legacy defaults',
    () {
      final json = rideJson();
      final legacy = RideModel.fromJson(json).toEntity();
      expect(legacy.discountMinor, 0);
      expect(legacy.promoApplied, isNull);
      final model = RideModel.fromJson({
        ...json,
        'promo': {'code': 'WELCOME50', 'applied': true},
        'fare': {
          'estimated': 3.45,
          'final': 1.75,
          'discount': 1.7,
          'currency': 'JOD',
        },
      });
      final ride = model.toEntity();
      expect(ride.promoCode, 'WELCOME50');
      expect(ride.discountMinor, 1700);
      expect(ride.fareFinalMinor, 1750);
      expect(ride.promoApplied, true);
      expect(RideModel.fromJson(model.toJson()), model);
    },
  );
  test(
    'request and schedule send only the promo code, never client discount',
    () async {
      final source = MockSource();
      final repository = RideRepositoryImpl(source);
      when(() => source.request(any())).thenAnswer((_) async => 'id');
      when(() => source.schedule(any())).thenAnswer((_) async => 'scheduled');
      await repository.requestRide(
        draft.withPromo('WELCOME50'),
        VehicleType.economy,
      );
      await repository.scheduleRide(
        draft.withPromo('WELCOME50'),
        VehicleType.economy,
      );
      for (final data in [
        verify(() => source.request(captureAny())).captured.single,
        verify(() => source.schedule(captureAny())).captured.single,
      ]) {
        expect((data as Map)['promoCode'], 'WELCOME50');
        expect(data.containsKey('discount'), false);
        expect(data.containsKey('fare'), false);
      }
    },
  );
  test('party snapshots and lifecycle dates round trip into domain', () {
    final time = Timestamp.fromDate(DateTime.utc(2026, 11, 17));
    final model = RideModel.fromJson({
      ...rideJson(),
      'driverInfo': {
        'name': 'Driver',
        'phone': '+962780000002',
        'rating': 4.8,
        'vehicle': {
          'type': 'comfort',
          'make': 'Toyota',
          'model': 'Corolla',
          'color': 'White',
          'plate': '12-34567',
        },
      },
      'riderInfo': {'name': 'Rider', 'phone': '+962780000001'},
      'acceptedAt': time,
      'arrivingAt': time,
      'arrivedAt': time,
      'startedAt': time,
      'completedAt': time,
      'fare': {'estimated': 2.5, 'final': 3.75, 'currency': 'JOD'},
    });
    expect(RideModel.fromJson(model.toJson()), model);
    final entity = model.toEntity();
    expect(entity.driverInfo!.name, 'Driver');
    expect(entity.acceptedAt, time.toDate().toUtc());
    expect(entity.driverInfo!.phone, '+962780000002');
    expect(entity.driverInfo!.rating, 4.8);
    expect(entity.driverInfo!.vehicle!.type, VehicleType.comfort);
    expect(entity.driverInfo!.vehicle!.plate, '12-34567');
    expect(entity.riderInfo!.rating, 5);
    expect(entity.riderInfo!.vehicle, isNull);
    expect(entity.arrivingAt, time.toDate().toUtc());
    expect(entity.arrivedAt, time.toDate().toUtc());
    expect(entity.startedAt, time.toDate().toUtc());
    expect(entity.completedAt, time.toDate().toUtc());
    expect(entity.fareFinalMinor, 3750);
    final legacy = RideModel.fromJson(rideJson()).toEntity();
    expect(legacy.driverInfo, isNull);
    expect(legacy.riderInfo, isNull);
    expect(legacy.startedAt, isNull);
  });
  test(
    'update status serializes status and maps typed action failures',
    () async {
      final source = MockSource();
      final repository = RideRepositoryImpl(source);
      when(
        () => source.updateStatus('ride', 'in_progress'),
      ).thenAnswer((_) async {});
      expect(
        await repository.updateStatus('ride', RideStatus.inProgress),
        const Right<Failure, Unit>(unit),
      );
      verify(() => source.updateStatus('ride', 'in_progress')).called(1);
      for (final entry in {
        'too-far': RideActionFailureReason.tooFar,
        'invalid-transition': RideActionFailureReason.invalidTransition,
      }.entries) {
        when(() => source.updateStatus('ride', 'arrived')).thenThrow(
          FirebaseFunctionsException(
            message: 'Rejected',
            code: 'failed-precondition',
            details: {'reason': entry.key},
          ),
        );
        expect(
          await repository.updateStatus('ride', RideStatus.arrived),
          Left<Failure, Unit>(RideActionFailure(entry.value)),
        );
      }
      for (final code in [
        'permission-denied',
        'unavailable',
        'failed-precondition',
      ]) {
        when(() => source.updateStatus('ride', 'arrived')).thenThrow(
          FirebaseFunctionsException(
            message: 'Rejected',
            code: code,
            details: const {'reason': 'unknown'},
          ),
        );
        final failure = (await repository.updateStatus(
          'ride',
          RideStatus.arrived,
        )).getLeft().toNullable();
        expect(
          failure,
          code == 'unavailable' ? isA<NetworkFailure>() : isA<ServerFailure>(),
        );
      }
    },
  );
  test('cancel exposes re-dispatch result and maps errors', () async {
    final source = MockSource();
    final repository = RideRepositoryImpl(source);
    for (final value in [false, true]) {
      when(() => source.cancel('ride')).thenAnswer((_) async => value);
      expect(
        await repository.cancelRide('ride'),
        Right<Failure, CancelRideResult>(CancelRideResult(redispatched: value)),
      );
    }
    when(
      () => source.cancel('ride'),
    ).thenThrow(
      FirebaseFunctionsException(message: 'Rejected', code: 'unavailable'),
    );
    expect(
      (await repository.cancelRide('ride')).getLeft().toNullable(),
      isA<NetworkFailure>(),
    );
  });
  test('accept and decline map success and offer failures', () async {
    final source = MockSource();
    final repository = RideRepositoryImpl(source);
    when(() => source.accept('ride')).thenAnswer((_) async {});
    when(() => source.decline('ride')).thenAnswer((_) async {});
    expect(
      await repository.acceptRide('ride'),
      const Right<Failure, Unit>(unit),
    );
    expect(
      await repository.declineRide('ride'),
      const Right<Failure, Unit>(unit),
    );
    for (final entry in {
      'offer-expired': OfferFailureReason.expired,
      'not-offered': OfferFailureReason.notOffered,
      'driver-busy': OfferFailureReason.driverBusy,
    }.entries) {
      when(() => source.accept('ride')).thenThrow(
        FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'Offer rejected',
          details: {'reason': entry.key},
        ),
      );
      expect(
        await repository.acceptRide('ride'),
        Left<Failure, Unit>(OfferFailure(entry.value)),
      );
    }
    when(
      () => source.accept('ride'),
    ).thenThrow(
      FirebaseFunctionsException(code: 'unavailable', message: 'Offline'),
    );
    when(
      () => source.decline('ride'),
    ).thenThrow(
      FirebaseFunctionsException(code: 'unavailable', message: 'Offline'),
    );
    expect(
      (await repository.acceptRide('ride')).getLeft().toNullable(),
      isA<NetworkFailure>(),
    );
    expect(
      (await repository.declineRide('ride')).getLeft().toNullable(),
      isA<NetworkFailure>(),
    );
  });
  test(
    'Firestore ride round-trip preserves nested data, timestamps and minor',
    () {
      final model = RideModel.fromJson(rideJson());
      expect(RideModel.fromJson(model.toJson()), model);
      final entity = model.toEntity();
      expect(entity.fareEstimatedMinor, 2550);
      expect(entity.offerDistanceMeters, 1200);
      expect(entity.offerExpiresAt, DateTime.utc(2026, 1, 1, 0, 0, 15));
      expect(entity.fareFinalMinor, isNull);
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
        expect(changed.toEntity().fareFinalMinor, 3200);
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
      when(() => source.cancel('ride')).thenAnswer((_) async => false);
      expect(
        await repository.cancelRide('ride'),
        const Right<Failure, CancelRideResult>(CancelRideResult()),
      );
      verify(() => source.cancel('ride')).called(1);
    },
  );
}
