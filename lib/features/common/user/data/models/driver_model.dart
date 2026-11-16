// Freezed forwards annotations to generated fields.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

@freezed
abstract class DriverModel with _$DriverModel {
  @JsonSerializable(explicitToJson: true)
  const factory DriverModel({
    @JsonKey(includeToJson: false) required String id,
    @JsonKey(unknownEnumValue: DriverStatus.pending)
    required DriverStatus status,
    required bool isOnline,
    required VehicleModel vehicle,
    String? licensePhotoPath,
    String? rejectionReason,
    String? currentRideId,
    DriverOfferModel? offer,
    DriverLocationModel? location,
    @Default(0) double heading,
    @TimestampConverter() DateTime? lastSeenAt,
  }) = _DriverModel;
  const DriverModel._();
  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
  factory DriverModel.fromFirestore(FirestoreDocument snapshot) =>
      DriverModel.fromJson({
        ...snapshot.data() ?? <String, dynamic>{},
        'id': snapshot.id,
      });
  factory DriverModel.fromEntity(DriverEntity entity) => DriverModel(
    id: entity.id,
    licensePhotoPath: entity.licensePhotoPath,
    rejectionReason: entity.rejectionReason,
    status: entity.status,
    isOnline: entity.isOnline,
    currentRideId: entity.currentRideId,
    offer: entity.offer == null
        ? null
        : DriverOfferModel.fromEntity(entity.offer!),
    vehicle: VehicleModel.fromEntity(entity.vehicle),
    location: entity.location == null
        ? null
        : DriverLocationModel.fromEntity(entity.location!),
    heading: entity.heading,
    lastSeenAt: entity.lastSeenAt,
  );
  DriverEntity toEntity() => DriverEntity(
    id: id,
    licensePhotoPath: licensePhotoPath,
    rejectionReason: rejectionReason,
    status: status,
    isOnline: isOnline,
    currentRideId: currentRideId,
    offer: offer?.toEntity(),
    vehicle: vehicle.toEntity(),
    location: location?.toEntity(),
    heading: heading,
    lastSeenAt: lastSeenAt,
  );
}

@freezed
abstract class DriverLocationModel with _$DriverLocationModel {
  const factory DriverLocationModel({
    @GeoPointConverter() required GeoPointValue geopoint,
    required String geohash,
  }) = _DriverLocationModel;
  const DriverLocationModel._();
  factory DriverLocationModel.fromJson(Map<String, dynamic> json) =>
      _$DriverLocationModelFromJson(json);
  factory DriverLocationModel.fromEntity(DriverLocation entity) =>
      DriverLocationModel(geopoint: entity.point, geohash: entity.geohash);
  DriverLocation toEntity() =>
      DriverLocation(point: geopoint, geohash: geohash);
}

@freezed
abstract class DriverOfferModel with _$DriverOfferModel {
  const factory DriverOfferModel({
    required String rideId,
    @TimestampConverter() required DateTime expiresAt,
    required int seq,
  }) = _DriverOfferModel;
  const DriverOfferModel._();
  factory DriverOfferModel.fromJson(Map<String, dynamic> json) =>
      _$DriverOfferModelFromJson(json);
  factory DriverOfferModel.fromEntity(DriverOffer offer) => DriverOfferModel(
    rideId: offer.rideId,
    expiresAt: offer.expiresAt,
    seq: offer.seq,
  );
  DriverOffer toEntity() =>
      DriverOffer(rideId: rideId, expiresAt: expiresAt, seq: seq);
}
