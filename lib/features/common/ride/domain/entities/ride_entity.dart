import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/parcel_details.dart';
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
    required this.fareEstimatedMinor,
    required this.createdAt,
    this.waitingFreeSeconds = 180,
    this.waitingRateMinor = 50,
    this.market = 'JO',
    this.currency = 'JOD',
    this.serviceType = ServiceType.ride,
    this.parcel,
    this.airport,
    this.scheduledFor,
    this.shareToken,
    this.promoCode,
    this.discountMinor = 0,
    this.fareCancellationFeeMinor = 0,
    this.fareWaitingFeeMinor = 0,
    this.farePreviousBalanceMinor = 0,
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
    this.fareFinalMinor,
    this.cancelledBy,
    this.searchExpiresAt,
    this.offerExpiresAt,
    this.offerDistanceMeters,
  });
  final int waitingFreeSeconds;
  final int waitingRateMinor;
  final String market;
  final String currency;
  final ServiceType serviceType;
  final ParcelDetails? parcel;
  final AirportDetails? airport;
  final String? shareToken;
  final String? promoCode;
  final int discountMinor;
  final int fareCancellationFeeMinor;
  final int fareWaitingFeeMinor;
  final int farePreviousBalanceMinor;
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
  final int fareEstimatedMinor;
  final int? fareFinalMinor;
  final String? cancelledBy;
  final DateTime createdAt;
  final DateTime? searchExpiresAt;
  final DateTime? offerExpiresAt;
  final int? offerDistanceMeters;
  RideDraft get draft => RideDraft(
    pickup: pickup,
    dropoff: dropoff,
    parcel: parcel,
    flightNumber: airport?.flightNumber,
  );
  @override
  List<Object?> get props => [
    waitingFreeSeconds,
    waitingRateMinor,
    market,
    currency,
    serviceType,
    airport,
    parcel,
    scheduledFor,
    shareToken,
    promoCode,
    discountMinor,
    fareCancellationFeeMinor,
    fareWaitingFeeMinor,
    farePreviousBalanceMinor,
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
    fareEstimatedMinor,
    fareFinalMinor,
    cancelledBy,
    createdAt,
    searchExpiresAt,
    offerExpiresAt,
    offerDistanceMeters,
  ];
}
