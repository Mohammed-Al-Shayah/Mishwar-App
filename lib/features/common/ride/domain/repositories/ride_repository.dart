import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

abstract class RideRepository {
  Future<Either<Failure, String>> requestRide(
    RideDraft draft,
    VehicleType vehicleType,
  );
  Future<Either<Failure, Unit>> cancelRide(String id);
  Future<Either<Failure, Unit>> acceptRide(String id);
  Future<Either<Failure, Unit>> declineRide(String id);
  Stream<Either<Failure, RideEntity>> watchRide(String id);
  Stream<Either<Failure, String?>> watchActiveRideId(String uid);
}
