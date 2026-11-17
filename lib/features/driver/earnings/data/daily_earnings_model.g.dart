// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_earnings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyEarningsModel _$DailyEarningsModelFromJson(Map<String, dynamic> json) =>
    _DailyEarningsModel(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      trips: (json['trips'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DailyEarningsModelToJson(_DailyEarningsModel instance) =>
    <String, dynamic>{'total': instance.total, 'trips': instance.trips};
