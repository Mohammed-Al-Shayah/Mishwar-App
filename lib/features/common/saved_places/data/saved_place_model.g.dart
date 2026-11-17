// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedPlaceModel _$SavedPlaceModelFromJson(Map<String, dynamic> json) =>
    _SavedPlaceModel(
      id: json['id'] as String,
      label: $enumDecode(_$SavedPlaceLabelEnumMap, json['label']),
      name: json['name'] as String,
      address: json['address'] as String,
      geopoint: const GeoPointConverter().fromJson(
        json['geopoint'] as GeoPoint,
      ),
      updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['updatedAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$SavedPlaceModelToJson(_SavedPlaceModel instance) =>
    <String, dynamic>{
      'label': _$SavedPlaceLabelEnumMap[instance.label]!,
      'name': instance.name,
      'address': instance.address,
      'geopoint': const GeoPointConverter().toJson(instance.geopoint),
      'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.updatedAt,
        const TimestampConverter().toJson,
      ),
    };

const _$SavedPlaceLabelEnumMap = {
  SavedPlaceLabel.home: 'home',
  SavedPlaceLabel.work: 'work',
  SavedPlaceLabel.other: 'other',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
