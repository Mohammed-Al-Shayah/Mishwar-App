import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/user/data/models/driver_model.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

// Firestore snapshots are mocked only at the model boundary.
// ignore: subtype_of_sealed_class
class MockDocument extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  final model = DriverModel(
    id: 'd',
    licensePhotoPath: 'drivers/d/license',
    rejectionReason: 'Blurry license',
    status: DriverStatus.approved,
    isOnline: false,
    vehicle: const VehicleModel(
      type: VehicleType.economy,
      make: 'Toyota',
      model: 'Corolla',
      color: 'White',
      plate: '12',
    ),
    location: const DriverLocationModel(
      geopoint: GeoPointValue(31, 35),
      geohash: 'hash',
    ),
    heading: 90,
    lastSeenAt: DateTime.utc(2026),
  );
  test('round trip retains nested Firestore fields and entities', () {
    final json = model.toJson();
    expect(DriverModel.fromJson({...json, 'id': model.id}), model);
    expect(json['location'], {
      'geopoint': const GeoPoint(31, 35),
      'geohash': 'hash',
    });
    expect(DriverModel.fromEntity(model.toEntity()), model);
    expect(model.toEntity().canGoOnline, isTrue);
    expect(
      model.copyWith(currentRideId: 'ride').toEntity().canGoOnline,
      isFalse,
    );
  });
  test('unknown status is pending and cannot go online', () {
    final parsed = DriverModel.fromJson({
      ...model.toJson(),
      'id': 'd',
      'status': 'future',
    });
    expect(parsed.status, DriverStatus.pending);
    expect(parsed.toEntity().canGoOnline, isFalse);
  });
  test('nullable location and timestamp round trip', () {
    final nullable = model.copyWith(
      location: null,
      lastSeenAt: null,
      licensePhotoPath: null,
      rejectionReason: null,
    );
    expect(DriverModel.fromJson({...nullable.toJson(), 'id': 'd'}), nullable);
  });
  test('snapshot injects id', () {
    final snapshot = MockDocument();
    when(() => snapshot.id).thenReturn('actual');
    when(snapshot.data).thenReturn(model.toJson());
    expect(DriverModel.fromFirestore(snapshot).id, 'actual');
  });
}
