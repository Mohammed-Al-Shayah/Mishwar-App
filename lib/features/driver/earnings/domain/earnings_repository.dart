import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';

abstract class EarningsRepository {
  Stream<Either<Failure, DailyEarnings>> watchDay(String uid, DateTime day);
  Future<Either<Failure, List<DailyEarnings>>> week(
    String uid,
    DateTime endingOn,
  );
}
