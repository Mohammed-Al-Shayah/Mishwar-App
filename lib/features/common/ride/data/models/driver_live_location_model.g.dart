// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_live_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverLiveLocationModel _$DriverLiveLocationModelFromJson(
  Map<String, dynamic> json,
) => _DriverLiveLocationModel(
  point: const GeoPointConverter().fromJson(json['geopoint'] as GeoPoint),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  heading: (json['heading'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DriverLiveLocationModelToJson(
  _DriverLiveLocationModel instance,
) => <String, dynamic>{
  'geopoint': const GeoPointConverter().toJson(instance.point),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'heading': instance.heading,
};
