// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) =>
    _VehicleModel(
      type: $enumDecode(
        _$VehicleTypeEnumMap,
        json['type'],
        unknownValue: VehicleType.economy,
      ),
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      plate: json['plate'] as String,
    );

Map<String, dynamic> _$VehicleModelToJson(_VehicleModel instance) =>
    <String, dynamic>{
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'make': instance.make,
      'model': instance.model,
      'color': instance.color,
      'plate': instance.plate,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.economy: 'economy',
  VehicleType.comfort: 'comfort',
  VehicleType.van: 'van',
};
