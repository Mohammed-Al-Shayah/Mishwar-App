import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class FareEstimate extends Equatable {
  const FareEstimate({required this.vehicleType, required this.fils});
  final VehicleType vehicleType;
  final int fils;
  @override
  List<Object> get props => [vehicleType, fils];
}
