// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RidePlaceModel _$RidePlaceModelFromJson(Map<String, dynamic> json) =>
    _RidePlaceModel(
      name: json['name'] as String,
      address: json['address'] as String,
      geopoint: const GeoPointConverter().fromJson(
        json['geopoint'] as GeoPoint,
      ),
    );

Map<String, dynamic> _$RidePlaceModelToJson(_RidePlaceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'geopoint': const GeoPointConverter().toJson(instance.geopoint),
    };

_RideFareModel _$RideFareModelFromJson(Map<String, dynamic> json) =>
    _RideFareModel(
      estimated: (json['estimated'] as num).toDouble(),
      currency: json['currency'] as String,
      finalAmount: (json['final'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RideFareModelToJson(_RideFareModel instance) =>
    <String, dynamic>{
      'estimated': instance.estimated,
      'currency': instance.currency,
      'final': instance.finalAmount,
    };

_RideModel _$RideModelFromJson(Map<String, dynamic> json) => _RideModel(
  id: json['id'] as String,
  riderId: json['riderId'] as String,
  status: const RideStatusConverter().fromJson(json['status'] as String),
  vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicleType']),
  pickup: RidePlaceModel.fromJson(json['pickup'] as Map<String, dynamic>),
  dropoff: RidePlaceModel.fromJson(json['dropoff'] as Map<String, dynamic>),
  fare: RideFareModel.fromJson(json['fare'] as Map<String, dynamic>),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  driverId: json['driverId'] as String?,
  route: json['route'] == null
      ? null
      : RouteModel.fromJson(json['route'] as Map<String, dynamic>),
  cancelledBy: json['cancelledBy'] as String?,
  searchExpiresAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['searchExpiresAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$RideModelToJson(_RideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderId': instance.riderId,
      'status': const RideStatusConverter().toJson(instance.status),
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'pickup': instance.pickup.toJson(),
      'dropoff': instance.dropoff.toJson(),
      'fare': instance.fare.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'driverId': instance.driverId,
      'route': instance.route?.toJson(),
      'cancelledBy': instance.cancelledBy,
      'searchExpiresAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.searchExpiresAt,
        const TimestampConverter().toJson,
      ),
    };

const _$VehicleTypeEnumMap = {
  VehicleType.economy: 'economy',
  VehicleType.comfort: 'comfort',
  VehicleType.van: 'van',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
