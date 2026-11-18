import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/ride/data/models/airport_details_model.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimate.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/entities/route_info.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
part 'route_models.freezed.dart';
part 'route_models.g.dart';

@freezed
abstract class RouteModel with _$RouteModel {
  const factory RouteModel({
    required String polyline,
    required int distanceMeters,
    required double durationSeconds,
  }) = _RouteModel;
  const RouteModel._();
  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
  RouteInfo toEntity() => RouteInfo(
    polyline: polyline,
    distanceMeters: distanceMeters,
    durationSeconds: durationSeconds,
  );
}

@freezed
abstract class FareEstimateModel with _$FareEstimateModel {
  const factory FareEstimateModel({
    required VehicleType vehicleType,
    required double amount,
    required String currency,
  }) = _FareEstimateModel;
  const FareEstimateModel._();
  factory FareEstimateModel.fromJson(Map<String, dynamic> json) =>
      _$FareEstimateModelFromJson(json);
  FareEstimate toEntity() {
    if (currency != 'JOD' || !amount.isFinite || amount < 0) {
      throw const FormatException('Invalid fare');
    }
    return FareEstimate(
      vehicleType: vehicleType,
      fils: (amount * 1000).round(),
    );
  }
}

@freezed
abstract class FareEstimatesModel with _$FareEstimatesModel {
  const factory FareEstimatesModel({
    required RouteModel route,
    required List<FareEstimateModel> fares,
    AirportDetailsModel? airport,
  }) = _FareEstimatesModel;
  const FareEstimatesModel._();
  factory FareEstimatesModel.fromJson(Map<String, dynamic> json) =>
      _$FareEstimatesModelFromJson(json);
  FareEstimates toEntity() => FareEstimates(
    route: route.toEntity(),
    airport: airport?.toEntity(),
    fares: List.unmodifiable(fares.map((fare) => fare.toEntity())),
  );
}
