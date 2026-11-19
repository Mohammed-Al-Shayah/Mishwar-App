import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';

part 'admin_record_model.freezed.dart';

@freezed
abstract class AdminRecordModel with _$AdminRecordModel {
  const factory AdminRecordModel({
    required String id,
    required Map<String, dynamic> fields,
  }) = _AdminRecordModel;
  const AdminRecordModel._();

  AdminEntry toEntity() {
    final vehicle = adminMap(fields['vehicle']);
    final rider = adminMap(fields['riderInfo']);
    final driver = adminMap(fields['driverInfo']);
    final fare = adminMap(fields['fare']);
    final location = adminMap(fields['location']);
    final point = location['geopoint'] as GeoPoint?;
    final currency = fare['currency'] == 'ILS' ? 'ILS' : 'JOD';
    int? minor(Object? value) => value is num
        ? (value * (currency == 'ILS' ? 100 : 1000)).round()
        : null;
    return AdminEntry(
      id: id,
      currency: currency,
      status: fields['status'] as String? ?? '',
      name: fields['name'] as String? ?? '',
      phone: fields['phone'] as String? ?? '',
      vehicle: [
        'make',
        'model',
        'color',
      ].map((k) => vehicle[k] ?? '').join(' ').trim(),
      plate: vehicle['plate'] as String? ?? '',
      rating: fields['rating'] as num? ?? 0,
      createdAt: (fields['createdAt'] as Timestamp?)?.toDate(),
      licensePath: fields['licensePhotoPath'] as String?,
      completed:
          (fields['completedTrips'] as num? ?? fields['tripCount'] as num? ?? 0)
              .toInt(),
      cancelled: (fields['cancelCount'] as num? ?? 0).toInt(),
      rider: rider['name'] as String? ?? fields['riderId'] as String? ?? '',
      driver: driver['name'] as String? ?? fields['driverId'] as String? ?? '',
      pickup: _placeName(fields['pickup']),
      dropoff: _placeName(fields['dropoff']),
      estimated: minor(fare['estimated']),
      finalFare: minor(fare['final']),
      riderRating: fields['riderRating'] is num
          ? fields['riderRating'] as num
          : adminMap(fields['riderRating'])['stars'] as num?,
      driverRating: fields['driverRating'] is num
          ? fields['driverRating'] as num
          : adminMap(fields['driverRating'])['stars'] as num?,
      timeline: {
        for (final key in [
          'createdAt',
          'acceptedAt',
          'arrivingAt',
          'arrivedAt',
          'startedAt',
          'completedAt',
          'cancelledAt',
        ])
          if (fields[key] is Timestamp)
            key: (fields[key] as Timestamp).toDate(),
      },
      lat: point?.latitude,
      lng: point?.longitude,
      busy: fields['currentRideId'] != null,
      reason:
          fields['suspensionReason'] as String? ??
          fields['rejectionReason'] as String? ??
          fields['cancellationReason'] as String? ??
          '',
    );
  }
}

/// Firestore web returns nested maps as `Map<dynamic, dynamic>`; copy, not
/// cast, so the admin console parses the same data on web and in tests.
Map<String, dynamic> adminMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

/// Place name for tables, falling back to the address.
String _placeName(Object? value) {
  final place = adminMap(value);
  return place['name'] as String? ?? place['address'] as String? ?? '';
}
