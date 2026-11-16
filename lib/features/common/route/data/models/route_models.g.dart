// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => _RouteModel(
  polyline: json['polyline'] as String,
  distanceMeters: (json['distanceMeters'] as num).toInt(),
  durationSeconds: (json['durationSeconds'] as num).toDouble(),
);

Map<String, dynamic> _$RouteModelToJson(_RouteModel instance) =>
    <String, dynamic>{
      'polyline': instance.polyline,
      'distanceMeters': instance.distanceMeters,
      'durationSeconds': instance.durationSeconds,
    };

_FareEstimateModel _$FareEstimateModelFromJson(Map<String, dynamic> json) =>
    _FareEstimateModel(
      vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicleType']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$FareEstimateModelToJson(_FareEstimateModel instance) =>
    <String, dynamic>{
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'amount': instance.amount,
      'currency': instance.currency,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.economy: 'economy',
  VehicleType.comfort: 'comfort',
  VehicleType.van: 'van',
};

_FareEstimatesModel _$FareEstimatesModelFromJson(Map<String, dynamic> json) =>
    _FareEstimatesModel(
      route: RouteModel.fromJson(json['route'] as Map<String, dynamic>),
      fares: (json['fares'] as List<dynamic>)
          .map((e) => FareEstimateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FareEstimatesModelToJson(_FareEstimatesModel instance) =>
    <String, dynamic>{'route': instance.route, 'fares': instance.fares};
