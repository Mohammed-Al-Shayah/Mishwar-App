import 'package:equatable/equatable.dart';

class RouteInfo extends Equatable {
  const RouteInfo({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });
  final String polyline;
  final int distanceMeters;
  final double durationSeconds;
  @override
  List<Object> get props => [polyline, distanceMeters, durationSeconds];
}
