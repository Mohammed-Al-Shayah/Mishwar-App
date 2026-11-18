import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_party_info.dart';
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
    this.scheduledFor,
    this.shareToken,
    this.promoCode,
    this.discountFils = 0,
    this.fareCancellationFeeFils = 0,
    this.fareWaitingFeeFils = 0,
    this.farePreviousBalanceFils = 0,
    this.promoApplied,
    this.driverRating,
    this.riderRating,
    this.driverId,
    this.driverInfo,
    this.riderInfo,
    this.acceptedAt,
    this.arrivingAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.route,
    this.fareFinalFils,
    this.cancelledBy,
    this.searchExpiresAt,
    this.offerExpiresAt,
    this.offerDistanceMeters,
  });
  final String? shareToken;
  final String? promoCode;
  final int discountFils;
  final int fareCancellationFeeFils;
  final int fareWaitingFeeFils;
  final int farePreviousBalanceFils;
  final bool? promoApplied;
  final DateTime? scheduledFor;
  final int? driverRating;
  final int? riderRating;
  final String id;
  final String riderId;
  final String? driverId;
  final RidePartyInfo? driverInfo;
  final RidePartyInfo? riderInfo;
  final DateTime? acceptedAt;
  final DateTime? arrivingAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
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
  final DateTime? offerExpiresAt;
  final int? offerDistanceMeters;
  RideDraft get draft => RideDraft(pickup: pickup, dropoff: dropoff);
  @override
  List<Object?> get props => [
    scheduledFor,
    shareToken,
    promoCode,
    discountFils,
    fareCancellationFeeFils,
    fareWaitingFeeFils,
    farePreviousBalanceFils,
    promoApplied,
    driverRating,
    riderRating,
    id,
    riderId,
    driverId,
    driverInfo,
    riderInfo,
    acceptedAt,
    arrivingAt,
    arrivedAt,
    startedAt,
    completedAt,
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
    offerExpiresAt,
    offerDistanceMeters,
  ];
}
