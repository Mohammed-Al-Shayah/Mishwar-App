import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';

@lazySingleton
class GetRideHistory {
  const GetRideHistory(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, RideHistoryPage>> call({
    required RideParty party,
    required String uid,
    HistoryCursor? after,
    int limit = 20,
  }) => _repository.history(party: party, uid: uid, after: after, limit: limit);
}
