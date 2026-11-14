import 'package:equatable/equatable.dart';

enum VehicleType { economy, comfort, van }

class VehicleEntity extends Equatable {
  const VehicleEntity({
    required this.type,
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
  });
  final VehicleType type;
  final String make;
  final String model;
  final String color;
  final String plate;

  @override
  List<Object?> get props => [type, make, model, color, plate];
}
