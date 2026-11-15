import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

abstract class LocationRepository {
  Future<Either<Failure, LocationPermissionStatus>> checkPermission();
  Future<Either<Failure, LocationPermissionStatus>> requestPermission();
  Future<Either<Failure, GeoPointValue>> currentPosition();
  Stream<Either<Failure, GeoPointValue>> watchPosition();
  Future<void> openAppSettings();
  Future<void> openLocationSettings();
}
