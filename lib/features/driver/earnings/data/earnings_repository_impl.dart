import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/driver/earnings/data/earnings_remote_data_source.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/earnings_repository.dart';

@LazySingleton(as: EarningsRepository)
class EarningsRepositoryImpl implements EarningsRepository {
  const EarningsRepositoryImpl(this._source);
  final EarningsRemoteDataSource _source;
  @override
  Stream<Either<Failure, DailyEarnings>> watchDay(
    String uid,
    DateTime day,
  ) async* {
    try {
      await for (final value in _source.watchDay(uid, day)) {
        yield Right(value);
      }
    } on Object catch (error) {
      yield Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<DailyEarnings>>> week(
    String uid,
    DateTime endingOn,
  ) async {
    try {
      return Right(await _source.week(uid, endingOn));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
