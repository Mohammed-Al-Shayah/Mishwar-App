import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/driver/earnings/data/daily_earnings_model.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';

@lazySingleton
class EarningsRemoteDataSource {
  const EarningsRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  DocumentReference<Map<String, dynamic>> _ref(String uid, DateTime day) =>
      _firestore.doc('drivers/$uid/earnings/${earningsDayKey(day)}');
  DailyEarnings _map(DateTime day, Map<String, dynamic>? data) =>
      DailyEarningsModel.fromJson(data ?? {}).toEntity(day);
  Stream<DailyEarnings> watchDay(String uid, DateTime day) =>
      _ref(uid, day).snapshots().map((doc) => _map(day, doc.data()));
  Future<List<DailyEarnings>> week(String uid, DateTime endingOn) =>
      Future.wait(
        List.generate(7, (index) async {
          final day = calendarDay(endingOn).subtract(Duration(days: 6 - index));
          return _map(day, (await _ref(uid, day).get()).data());
        }),
      );
}
