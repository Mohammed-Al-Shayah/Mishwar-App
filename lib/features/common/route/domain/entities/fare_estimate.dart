import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class FareEstimate extends Equatable {
  const FareEstimate({
    required this.vehicleType,
    required this.minor,
    this.currency = 'JOD',
  });
  final VehicleType vehicleType;
  final int minor;
  final String currency;
  @override
  List<Object> get props => [vehicleType, minor, currency];
}
