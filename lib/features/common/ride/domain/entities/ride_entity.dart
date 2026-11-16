import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/route/domain/entities/route_info.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

enum RideStatus {
  scheduled,
  searching,
  accepted,
  arriving,
  arrived,
  inProgress,
  completed,
  cancelled,
  noDrivers,
}

typedef RidePlace = RideStop;

class RideEntity extends Equatable {
  const RideEntity({
    required this.id,
    required this.riderId,
    required this.status,
    required this.vehicleType,
    required this.pickup,
    required this.dropoff,
    required this.fareEstimatedFils,
    required this.createdAt,
    this.driverId,
    this.route,
    this.fareFinalFils,
    this.cancelledBy,
    this.searchExpiresAt,
  });
  final String id;
  final String riderId;
  final String? driverId;
  final RideStatus status;
  final VehicleType vehicleType;
  final RidePlace pickup;
  final RidePlace dropoff;
  final RouteInfo? route;
  final int fareEstimatedFils;
  final int? fareFinalFils;
  final String? cancelledBy;
  final DateTime createdAt;
  final DateTime? searchExpiresAt;
  RideDraft get draft => RideDraft(pickup: pickup, dropoff: dropoff);
  @override
  List<Object?> get props => [
    id,
    riderId,
    driverId,
    status,
    vehicleType,
    pickup,
    dropoff,
    route,
    fareEstimatedFils,
    fareFinalFils,
    cancelledBy,
    createdAt,
    searchExpiresAt,
  ];
}
