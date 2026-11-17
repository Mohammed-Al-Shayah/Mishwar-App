import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/earnings_repository.dart';

@lazySingleton
class GetWeekEarnings {
  const GetWeekEarnings(this._repository);
  final EarningsRepository _repository;
  Future<Either<Failure, List<DailyEarnings>>> call(String uid, DateTime day) =>
      _repository.week(uid, day);
}
