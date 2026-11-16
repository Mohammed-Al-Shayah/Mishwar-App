// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceSuggestionModel _$PlaceSuggestionModelFromJson(
  Map<String, dynamic> json,
) => _PlaceSuggestionModel(
  placeId: json['placeId'] as String,
  primaryText: json['primaryText'] as String,
  secondaryText: json['secondaryText'] as String,
);

Map<String, dynamic> _$PlaceSuggestionModelToJson(
  _PlaceSuggestionModel instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'primaryText': instance.primaryText,
  'secondaryText': instance.secondaryText,
};

_PlaceDetailsModel _$PlaceDetailsModelFromJson(Map<String, dynamic> json) =>
    _PlaceDetailsModel(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$PlaceDetailsModelToJson(_PlaceDetailsModel instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
    };
