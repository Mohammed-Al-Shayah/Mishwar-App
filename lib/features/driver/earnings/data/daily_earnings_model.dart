import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';

part 'daily_earnings_model.freezed.dart';
part 'daily_earnings_model.g.dart';

@freezed
abstract class DailyEarningsModel with _$DailyEarningsModel {
  const factory DailyEarningsModel({
    @Default('JOD') String currency,
    @Default(0.0) double total,
    @Default(0) int trips,
  }) = _DailyEarningsModel;
  const DailyEarningsModel._();
  factory DailyEarningsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyEarningsModelFromJson(json);

  DailyEarnings toEntity(DateTime day) {
    if (!total.isFinite || total < 0 || trips < 0) {
      throw const FormatException('Invalid earnings');
    }
    return DailyEarnings(
      day: calendarDay(day),
      currency: currency,
      totalMinor: (total * Money.scale(currency)).round(),
      trips: trips,
    );
  }
}
