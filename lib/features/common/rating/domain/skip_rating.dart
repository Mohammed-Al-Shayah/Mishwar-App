import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class SkipRating {
  const SkipRating(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, Unit>> call(String rideId) =>
      _repository.skipRating(rideId);
}
