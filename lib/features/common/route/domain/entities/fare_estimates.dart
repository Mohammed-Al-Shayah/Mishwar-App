import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimate.dart';
import 'package:mishwar/features/common/route/domain/entities/route_info.dart';

class FareEstimates extends Equatable {
  FareEstimates({
    required this.route,
    required List<FareEstimate> fares,
    this.airport,
  }) : fares = List.unmodifiable(fares);
  final RouteInfo route;
  final AirportDetails? airport;
  final List<FareEstimate> fares;
  @override
  List<Object?> get props => [route, fares, airport];
}
