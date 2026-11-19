import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/driver/earnings/data/daily_earnings_model.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';

@lazySingleton
class EarningsRemoteDataSource {
  const EarningsRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  DailyEarnings _map(DateTime day, Map<String, dynamic>? data) =>
      DailyEarningsModel.fromJson(data ?? {}).toEntity(day);
  DailyEarnings _combine(DateTime day, List<Map<String, dynamic>> docs) {
    final values = docs.map((d) => _map(day, d)).toList();
    return DailyEarnings(
      day: day,
      totalMinor:
          values.where((d) => d.currency == 'JOD').firstOrNull?.totalMinor ?? 0,
      trips: values.where((d) => d.currency == 'JOD').firstOrNull?.trips ?? 0,
      totals: {for (final d in values) d.currency: d.totalMinor},
      tripCounts: {for (final d in values) d.currency: d.trips},
    );
  }

  Stream<DailyEarnings> watchDay(String uid, DateTime day) => Stream.multi((
    controller,
  ) {
    final latest = <String, Map<String, dynamic>>{};
    final subscriptions =
        <StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>[];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    try {
      subscriptions.addAll(
        ['JO', 'PS']
            .map(
              (market) => _firestore
                  .doc('drivers/$uid/earnings/${earningsDayKey(day)}_$market')
                  .snapshots()
                  .listen((doc) {
                    latest[market] = {
                      ...?doc.data(),
                      'currency': market == 'PS' ? 'ILS' : 'JOD',
                    };
                    if (latest.length == 2) {
                      controller.add(_combine(day, latest.values.toList()));
                    }
                  }, onError: controller.addError),
            )
            .toList(),
      );
    } on Object catch (error, stack) {
      controller.addError(error, stack);
      unawaited(controller.close());
    }
  });
  Future<List<DailyEarnings>> week(String uid, DateTime endingOn) =>
      Future.wait(
        List.generate(7, (index) async {
          final day = calendarDay(endingOn).subtract(Duration(days: 6 - index));
          final docs = await Future.wait(
            ['JO', 'PS'].map(
              (m) => _firestore
                  .doc('drivers/$uid/earnings/${earningsDayKey(day)}_$m')
                  .get(),
            ),
          );
          return _combine(
            day,
            docs.where((d) => d.exists).map((d) => d.data()!).toList(),
          );
        }),
      );
}
