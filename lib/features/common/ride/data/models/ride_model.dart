import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_party_info.dart';
import 'package:mishwar/features/common/route/data/models/route_models.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

class RideStatusConverter implements JsonConverter<RideStatus, String> {
  const RideStatusConverter();
  @override
  RideStatus fromJson(String json) => switch (json) {
    'in_progress' => RideStatus.inProgress,
    'no_drivers' => RideStatus.noDrivers,
    _ => RideStatus.values.byName(json),
  };
  @override
  String toJson(RideStatus value) => switch (value) {
    RideStatus.inProgress => 'in_progress',
    RideStatus.noDrivers => 'no_drivers',
    _ => value.name,
  };
}

@freezed
abstract class RidePlaceModel with _$RidePlaceModel {
  const factory RidePlaceModel({
    required String name,
    required String address,
    @GeoPointConverter() required GeoPointValue geopoint,
  }) = _RidePlaceModel;
  const RidePlaceModel._();
  factory RidePlaceModel.fromJson(Map<String, dynamic> json) =>
      _$RidePlaceModelFromJson(json);
  RidePlace toEntity() =>
      RidePlace(name: name, address: address, location: geopoint);
}

@freezed
abstract class RideFareModel with _$RideFareModel {
  const factory RideFareModel({
    required double estimated,
    required String currency,
    @JsonKey(name: 'final') double? finalAmount,
  }) = _RideFareModel;
  factory RideFareModel.fromJson(Map<String, dynamic> json) =>
      _$RideFareModelFromJson(json);
}

@freezed
abstract class RideModel with _$RideModel {
  // Freezed forwards this annotation to its generated implementation.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory RideModel({
    required String id,
    required String riderId,
    @RideStatusConverter() required RideStatus status,
    required VehicleType vehicleType,
    required RidePlaceModel pickup,
    required RidePlaceModel dropoff,
    required RideFareModel fare,
    @TimestampConverter() required DateTime createdAt,
    String? driverId,
    RidePartyInfoModel? driverInfo,
    RidePartyInfoModel? riderInfo,
    @TimestampConverter() DateTime? acceptedAt,
    @TimestampConverter() DateTime? arrivingAt,
    @TimestampConverter() DateTime? arrivedAt,
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? completedAt,
    RouteModel? route,
    String? cancelledBy,
    @TimestampConverter() DateTime? searchExpiresAt,
    @TimestampConverter() DateTime? offerExpiresAt,
    int? offerDistanceMeters,
  }) = _RideModel;
  const RideModel._();
  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);
  RideEntity toEntity() {
    if (fare.currency != 'JOD' ||
        !fare.estimated.isFinite ||
        fare.estimated < 0 ||
        (fare.finalAmount != null &&
            (!fare.finalAmount!.isFinite || fare.finalAmount! < 0))) {
      throw const FormatException('Invalid fare');
    }
    return RideEntity(
      id: id,
      riderId: riderId,
      driverId: driverId,
      driverInfo: driverInfo?.toEntity(),
      riderInfo: riderInfo?.toEntity(),
      acceptedAt: acceptedAt,
      arrivingAt: arrivingAt,
      arrivedAt: arrivedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      status: status,
      vehicleType: vehicleType,
      pickup: pickup.toEntity(),
      dropoff: dropoff.toEntity(),
      route: route?.toEntity(),
      fareEstimatedFils: (fare.estimated * 1000).round(),
      fareFinalFils: fare.finalAmount == null
          ? null
          : (fare.finalAmount! * 1000).round(),
      cancelledBy: cancelledBy,
      createdAt: createdAt,
      searchExpiresAt: searchExpiresAt,
      offerExpiresAt: offerExpiresAt,
      offerDistanceMeters: offerDistanceMeters,
    );
  }
}

@freezed
abstract class RidePartyInfoModel with _$RidePartyInfoModel {
  // Freezed forwards this annotation to its generated implementation.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory RidePartyInfoModel({
    required String name,
    required String phone,
    @Default(5.0) double rating,
    VehicleModel? vehicle,
  }) = _RidePartyInfoModel;
  const RidePartyInfoModel._();
  factory RidePartyInfoModel.fromJson(Map<String, dynamic> json) =>
      _$RidePartyInfoModelFromJson(json);
  RidePartyInfo toEntity() => RidePartyInfo(
    name: name,
    phone: phone,
    rating: rating,
    vehicle: vehicle?.toEntity(),
  );
}
