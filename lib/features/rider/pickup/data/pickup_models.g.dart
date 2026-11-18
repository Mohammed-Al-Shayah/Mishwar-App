// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PickupAddressModel _$PickupAddressModelFromJson(Map<String, dynamic> json) =>
    _PickupAddressModel(
      name: json['name'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$PickupAddressModelToJson(_PickupAddressModel instance) =>
    <String, dynamic>{'name': instance.name, 'address': instance.address};

_PickupSuggestionModel _$PickupSuggestionModelFromJson(
  Map<String, dynamic> json,
) => _PickupSuggestionModel(
  id: json['id'] as String,
  name: json['name'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  distanceMeters: (json['distanceMeters'] as num).toDouble(),
);

Map<String, dynamic> _$PickupSuggestionModelToJson(
  _PickupSuggestionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'lat': instance.lat,
  'lng': instance.lng,
  'distanceMeters': instance.distanceMeters,
};
