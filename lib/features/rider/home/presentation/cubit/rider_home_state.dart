import 'package:equatable/equatable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class RiderHomeState extends Equatable {
  const RiderHomeState({
    this.permission = LocationPermissionStatus.denied,
    this.position,
    this.isLocating = false,
    this.failure,
  });
  final LocationPermissionStatus permission;
  final GeoPointValue? position;
  final bool isLocating;
  final Failure? failure;
  @override
  List<Object?> get props => [permission, position, isLocating, failure];
}
