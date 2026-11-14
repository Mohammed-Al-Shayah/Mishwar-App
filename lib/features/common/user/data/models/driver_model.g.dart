// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverModel _$DriverModelFromJson(Map<String, dynamic> json) => _DriverModel(
  id: json['id'] as String,
  status: $enumDecode(
    _$DriverStatusEnumMap,
    json['status'],
    unknownValue: DriverStatus.pending,
  ),
  isOnline: json['isOnline'] as bool,
  vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
  currentRideId: json['currentRideId'] as String?,
  location: json['location'] == null
      ? null
      : DriverLocationModel.fromJson(json['location'] as Map<String, dynamic>),
  heading: (json['heading'] as num?)?.toDouble() ?? 0,
  lastSeenAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['lastSeenAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$DriverModelToJson(_DriverModel instance) =>
    <String, dynamic>{
      'status': _$DriverStatusEnumMap[instance.status]!,
      'isOnline': instance.isOnline,
      'vehicle': instance.vehicle.toJson(),
      'currentRideId': instance.currentRideId,
      'location': instance.location?.toJson(),
      'heading': instance.heading,
      'lastSeenAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.lastSeenAt,
        const TimestampConverter().toJson,
      ),
    };

const _$DriverStatusEnumMap = {
  DriverStatus.pending: 'pending',
  DriverStatus.approved: 'approved',
  DriverStatus.rejected: 'rejected',
  DriverStatus.suspended: 'suspended',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_DriverLocationModel _$DriverLocationModelFromJson(Map<String, dynamic> json) =>
    _DriverLocationModel(
      geopoint: const GeoPointConverter().fromJson(
        json['geopoint'] as GeoPoint,
      ),
      geohash: json['geohash'] as String,
    );

Map<String, dynamic> _$DriverLocationModelToJson(
  _DriverLocationModel instance,
) => <String, dynamic>{
  'geopoint': const GeoPointConverter().toJson(instance.geopoint),
  'geohash': instance.geohash,
};
