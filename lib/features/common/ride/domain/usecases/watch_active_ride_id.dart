import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class WatchActiveRideId {
  const WatchActiveRideId(this._repository);
  final RideRepository _repository;
  Stream<Either<Failure, String?>> call(String uid) =>
      _repository.watchActiveRideId(uid);
}
