import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class UpdateRideStatus {
  const UpdateRideStatus(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, Unit>> call(
    String rideId,
    RideStatus status, {
    String? deliveryCode,
  }) => deliveryCode == null
      ? _repository.updateStatus(rideId, status)
      : _repository.updateStatus(rideId, status, deliveryCode: deliveryCode);
}
