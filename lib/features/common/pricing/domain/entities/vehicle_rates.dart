import 'package:equatable/equatable.dart';

/// All rates are integer fils (1 JOD = 1000 fils).
class VehicleRates extends Equatable {
  const VehicleRates({
    required this.base,
    required this.perKm,
    required this.perMin,
    required this.minimum,
  }) : assert(base >= 0, 'Rate must be nonnegative'),
       assert(perKm >= 0, 'Rate must be nonnegative'),
       assert(perMin >= 0, 'Rate must be nonnegative'),
       assert(minimum >= 0, 'Rate must be nonnegative');
  final int base;
  final int perKm;
  final int perMin;
  final int minimum;
  @override
  List<Object> get props => [base, perKm, perMin, minimum];
}
