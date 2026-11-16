import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class DriverLiveLocation extends Equatable {
  const DriverLiveLocation({
    required this.point,
    required this.updatedAt,
    this.heading,
  });
  final GeoPointValue point;
  final double? heading;
  final DateTime updatedAt;
  @override
  List<Object?> get props => [point, heading, updatedAt];
}
