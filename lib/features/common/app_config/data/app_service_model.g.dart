// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppServiceModel _$AppServiceModelFromJson(Map<String, dynamic> json) =>
    _AppServiceModel(
      id: $enumDecode(_$ServiceIdEnumMap, json['id']),
      enabled: json['enabled'] as bool,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$AppServiceModelToJson(_AppServiceModel instance) =>
    <String, dynamic>{
      'id': _$ServiceIdEnumMap[instance.id]!,
      'enabled': instance.enabled,
      'order': instance.order,
    };

const _$ServiceIdEnumMap = {
  ServiceId.ride: 'ride',
  ServiceId.schedule: 'schedule',
  ServiceId.parcel: 'parcel',
  ServiceId.airport: 'airport',
};
