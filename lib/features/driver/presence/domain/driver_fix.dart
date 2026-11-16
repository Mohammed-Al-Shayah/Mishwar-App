import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class DriverFix extends Equatable {
  const DriverFix(this.point, {this.heading});
  final GeoPointValue point;
  final double? heading;
  @override
  List<Object?> get props => [point, heading];
}
