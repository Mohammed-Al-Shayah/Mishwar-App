import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_reports.dart';

@LazySingleton(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._db);
  final FirebaseFirestore _db;
  @override
  Future<Either<Failure, ReportData>> load(
    int days, [
    String market = 'JO',
  ]) async {
    if (![7, 30, 90].contains(days)) {
      return const Left(ServerFailure('report-range'));
    }
    try {
      final last = ammanToday(DateTime.now());
      final first = last.subtract(Duration(days: days - 1));
      final snapshots = await _db
          .collection('stats')
          .where(
            FieldPath.documentId,
            isGreaterThanOrEqualTo: reportDayKey(first),
          )
          .where(
            FieldPath.documentId,
            isLessThanOrEqualTo: '${reportDayKey(last)}_ZZ',
          )
          .get();
      Map<String, int> counts(Map<Object?, Object?> raw) => {
        for (final e in raw.entries)
          if (e.value is num) e.key! as String: (e.value! as num).toInt(),
      };
      final byDay = {
        for (final doc in snapshots.docs.where(
          (d) => d.data()['market'] == market,
        ))
          doc.id.substring(0, 10): ReportDay(
            day: doc.id.substring(0, 10),
            counts: counts(doc.data()),
            promos: counts(doc.data()['promoUsesByCode'] as Map? ?? {}),
          ),
      };
      return Right(
        ReportData([
          for (var i = 0; i < days; i++)
            byDay[reportDayKey(first.add(Duration(days: i)))] ??
                ReportDay(day: reportDayKey(first.add(Duration(days: i)))),
        ], market: market),
      );
    } on Object {
      return const Left(ServerFailure('reports-load'));
    }
  }
}
