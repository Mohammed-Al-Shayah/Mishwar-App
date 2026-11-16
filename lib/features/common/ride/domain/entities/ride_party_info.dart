import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class RidePartyInfo extends Equatable {
  const RidePartyInfo({
    required this.name,
    required this.phone,
    this.rating = 5.0,
    this.vehicle,
  });
  final String name;
  final String phone;
  final double rating;
  final VehicleEntity? vehicle;
  @override
  List<Object?> get props => [name, phone, rating, vehicle];
}
