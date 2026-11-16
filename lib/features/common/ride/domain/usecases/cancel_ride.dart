import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class CancelRide {
  const CancelRide(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, CancelRideResult>> call(String id) =>
      _repository.cancelRide(id);
}
