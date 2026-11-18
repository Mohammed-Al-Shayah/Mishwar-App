import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class WatchScheduledRides {
  const WatchScheduledRides(this._repository);
  final RideRepository _repository;
  Stream<Either<Failure, List<RideEntity>>> call(String id) =>
      _repository.watchScheduledRides(id);
}
