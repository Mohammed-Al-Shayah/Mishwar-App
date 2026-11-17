import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class RateRide {
  const RateRide(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, Unit>> call(
    String rideId,
    int stars,
    List<RatingTag> tags,
    String comment,
  ) => _repository.rateRide(rideId, stars, tags, comment);
}
