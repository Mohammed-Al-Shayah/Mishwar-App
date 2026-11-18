import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/parcel_details.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class RideStop extends Equatable {
  const RideStop({
    required this.name,
    required this.address,
    required this.location,
  });
  final String name;
  final String address;
  final GeoPointValue location;
  @override
  List<Object> get props => [name, address, location];
}

class RideDraft extends Equatable {
  const RideDraft({
    required this.pickup,
    required this.dropoff,
    this.parcel,
    this.flightNumber,
    this.scheduledFor,
    this.promoCode,
  });
  final ParcelDetails? parcel;
  final String? flightNumber;
  ServiceType get serviceType =>
      parcel == null ? ServiceType.ride : ServiceType.parcel;
  final String? promoCode;
  RideDraft withPickup(RideStop stop) => RideDraft(
    pickup: stop,
    dropoff: dropoff,
    scheduledFor: scheduledFor,
    promoCode: promoCode,
    parcel: parcel,
    flightNumber: flightNumber,
  );
  RideDraft withPromo(String? code) => RideDraft(
    pickup: pickup,
    dropoff: dropoff,
    scheduledFor: scheduledFor,
    promoCode: code,
    parcel: parcel,
    flightNumber: flightNumber,
  );
  final DateTime? scheduledFor;
  final RideStop pickup;
  final RideStop dropoff;
  @override
  List<Object?> get props => [
    pickup,
    dropoff,
    scheduledFor,
    promoCode,
    parcel,
    flightNumber,
  ];
}
