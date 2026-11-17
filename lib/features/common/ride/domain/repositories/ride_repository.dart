import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

abstract class RideRepository {
  Future<Either<Failure, RideHistoryPage>> history({
    required RideParty party,
    required String uid,
    HistoryCursor? after,
    int limit = 20,
  });
  Future<Either<Failure, Unit>> rateRide(
    String rideId,
    int stars,
    List<RatingTag> tags,
    String comment,
  );
  Future<Either<Failure, Unit>> skipRating(String rideId);
  Future<Either<Failure, String>> requestRide(
    RideDraft draft,
    VehicleType vehicleType,
  );
  Future<Either<Failure, CancelRideResult>> cancelRide(String id);
  Future<Either<Failure, Unit>> updateStatus(String rideId, RideStatus status);
  Future<Either<Failure, Unit>> acceptRide(String id);
  Future<Either<Failure, Unit>> declineRide(String id);
  Stream<Either<Failure, DriverLiveLocation>> watchDriverLocation(
    String rideId,
  );
  Stream<Either<Failure, RideEntity>> watchRide(String id);
  Stream<Either<Failure, String?>> watchActiveRideId(String uid);
}
