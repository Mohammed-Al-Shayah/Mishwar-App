import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';

class ReportDay extends Equatable {
  ReportDay({
    required this.day,
    Map<String, int> counts = const {},
    Map<String, int> promos = const {},
  }) : counts = Map.unmodifiable(counts),
       promos = Map.unmodifiable(promos);
  final String day;
  final Map<String, int> counts;
  final Map<String, int> promos;
  int count(String key) => counts[key] ?? 0;
  int get cancellations =>
      count('cancelledByRider') +
      count('cancelledByDriver') +
      count('cancelledBySystem');
  @override
  List<Object?> get props => [day, counts, promos];
}

class ReportData extends Equatable {
  ReportData(List<ReportDay> days, {this.market = 'JO'})
    : days = List.unmodifiable(days);
  final String market;
  String get currency => market == 'PS' ? 'ILS' : 'JOD';
  int get scale => Money.scale(currency);
  final List<ReportDay> days;
  int total(String key) => days.fold(0, (sum, d) => sum + d.count(key));
  int get cancellations => days.fold(0, (sum, d) => sum + d.cancellations);
  double get completionRate => total('requested') == 0
      ? 0
      : total('completed') / total('requested') * 100;
  double get cancellationRate =>
      total('requested') == 0 ? 0 : cancellations / total('requested') * 100;
  double get averageFare => total('completed') == 0
      ? 0
      : total('revenueMinor') / total('completed') / scale;
  List<MapEntry<String, int>> get topPromos {
    final totals = <String, int>{};
    for (final d in days) {
      for (final p in d.promos.entries) {
        totals[p.key] = (totals[p.key] ?? 0) + p.value;
      }
    }
    return totals.entries.toList()..sort((a, b) {
      final byUses = b.value.compareTo(a.value);
      return byUses == 0 ? a.key.compareTo(b.key) : byUses;
    });
  }

  String csv(List<String> headings) {
    String escape(Object value) =>
        '"${value.toString().replaceAll('"', '""')}"';
    final rows = <List<Object>>[
      headings,
      for (final d in days)
        [
          d.day,
          d.count('requested'),
          d.count('completed'),
          (d.count('revenueMinor') / scale).toStringAsFixed(3),
          (d.count('discountMinor') / scale).toStringAsFixed(3),
          d.count('cancelledByRider'),
          d.count('cancelledByDriver'),
          d.count('cancelledBySystem'),
          d.count('noDrivers'),
          d.count('promoUses'),
          d.count('parcels'),
          d.count('airport'),
          d.count('scheduled'),
        ],
    ];
    return '\ufeff${rows.map((r) => r.map(escape).join(',')).join('\r\n')}\r\n';
  }

  @override
  List<Object?> get props => [days, market];
}

// One read boundary for the reports use case.
// ignore: one_member_abstracts
abstract interface class ReportsRepository {
  Future<Either<Failure, ReportData>> load(int days, [String market = 'JO']);
}

@lazySingleton
class LoadReports {
  const LoadReports(this._repository);
  final ReportsRepository _repository;
  Future<Either<Failure, ReportData>> call(int days, [String market = 'JO']) =>
      _repository.load(days, market);
}

/// Calendar dates in Asia/Amman (UTC+3); do not use the browser's local zone.
DateTime ammanToday(DateTime now) {
  final d = now.toUtc().add(const Duration(hours: 3));
  return DateTime.utc(d.year, d.month, d.day);
}

String reportDayKey(DateTime date) => date.toIso8601String().substring(0, 10);
