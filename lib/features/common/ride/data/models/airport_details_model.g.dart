// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AirportDetailsModel _$AirportDetailsModelFromJson(Map<String, dynamic> json) =>
    _AirportDetailsModel(
      direction: const AirportDirectionConverter().fromJson(
        json['direction'] as String,
      ),
      flightNumber: json['flightNumber'] as String?,
      fixedFare: json['fixedFare'] as bool? ?? true,
    );

Map<String, dynamic> _$AirportDetailsModelToJson(
  _AirportDetailsModel instance,
) => <String, dynamic>{
  'direction': const AirportDirectionConverter().toJson(instance.direction),
  'flightNumber': instance.flightNumber,
  'fixedFare': instance.fixedFare,
};
