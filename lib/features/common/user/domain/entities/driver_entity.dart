import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

enum DriverStatus { pending, approved, rejected, suspended }

class DriverLocation extends Equatable {
  const DriverLocation({required this.point, required this.geohash});
  final GeoPointValue point;
  final String geohash;
  @override
  List<Object?> get props => [point, geohash];
}

class DriverEntity extends Equatable {
  const DriverEntity({
    required this.id,
    required this.status,
    required this.isOnline,
    required this.vehicle,
    this.pendingRatingRideId,
    this.licensePhotoPath,
    this.rejectionReason,
    this.currentRideId,
    this.location,
    this.heading = 0,
    this.lastSeenAt,
    this.offer,
  });
  final String? licensePhotoPath;
  final String? rejectionReason;
  final String id;
  final String? pendingRatingRideId;
  final DriverStatus status;
  final bool isOnline;
  final String? currentRideId;
  final VehicleEntity vehicle;
  final DriverLocation? location;
  final double heading;
  final DateTime? lastSeenAt;
  final DriverOffer? offer;

  bool get canGoOnline =>
      status == DriverStatus.approved && currentRideId == null;
  @override
  List<Object?> get props => [
    id,
    pendingRatingRideId,
    status,
    isOnline,
    currentRideId,
    vehicle,
    location,
    heading,
    lastSeenAt,
    offer,
    licensePhotoPath,
    rejectionReason,
  ];
}

class DriverOffer extends Equatable {
  const DriverOffer({
    required this.rideId,
    required this.expiresAt,
    required this.seq,
  });
  final String rideId;
  final DateTime expiresAt;
  final int seq;
  @override
  List<Object> get props => [rideId, expiresAt, seq];
}
