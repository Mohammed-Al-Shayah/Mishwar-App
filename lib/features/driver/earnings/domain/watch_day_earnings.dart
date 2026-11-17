import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/earnings_repository.dart';

@lazySingleton
class WatchDayEarnings {
  const WatchDayEarnings(this._repository);
  final EarningsRepository _repository;
  Stream<Either<Failure, DailyEarnings>> call(String uid, DateTime day) =>
      _repository.watchDay(uid, day);
}
