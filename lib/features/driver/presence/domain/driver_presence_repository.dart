import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';

abstract class DriverPresenceRepository {
  Future<Either<Failure, Unit>> goOnline(
    GeoPointValue point, {
    double? heading,
  });
  Future<Either<Failure, Unit>> publishTripLocation(
    String rideId,
    GeoPointValue point, {
    double? heading,
  });
  Future<Either<Failure, Unit>> goOffline();
  Future<Either<Failure, Unit>> updateLocation(
    GeoPointValue point, {
    double? heading,
  });
}

// Repository boundary keeps platform streams out of the domain and Bloc.
// ignore: one_member_abstracts
abstract class DriverTrackingRepository {
  Stream<Either<Failure, DriverFix>> watch({
    required String notificationTitle,
    required String notificationText,
  });
}
