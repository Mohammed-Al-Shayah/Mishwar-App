import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class DeclineRide {
  const DeclineRide(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, Unit>> call(String id) => _repository.declineRide(id);
}
