import 'package:equatable/equatable.dart';
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
    this.scheduledFor,
    this.promoCode,
  });
  final String? promoCode;
  RideDraft withPromo(String? code) => RideDraft(
    pickup: pickup,
    dropoff: dropoff,
    scheduledFor: scheduledFor,
    promoCode: code,
  );
  final DateTime? scheduledFor;
  final RideStop pickup;
  final RideStop dropoff;
  @override
  List<Object?> get props => [pickup, dropoff, scheduledFor, promoCode];
}
