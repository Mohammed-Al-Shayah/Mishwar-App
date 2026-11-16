import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class WatchDriverLocation {
  const WatchDriverLocation(this._repository);
  final RideRepository _repository;
  Stream<Either<Failure, DriverLiveLocation>> call(String rideId) =>
      _repository.watchDriverLocation(rideId);
}
