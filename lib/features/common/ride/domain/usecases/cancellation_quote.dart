import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class CancellationQuote {
  const CancellationQuote(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, int>> call(String rideId) =>
      _repository.cancellationQuote(rideId);
}
