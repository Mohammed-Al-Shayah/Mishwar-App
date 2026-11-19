import 'package:equatable/equatable.dart';

class DailyEarnings extends Equatable {
  const DailyEarnings({
    required this.day,
    this.totalMinor = 0,
    this.trips = 0,
    this.currency = 'JOD',
    this.totals = const {},
    this.tripCounts = const {},
  });
  final String currency;
  final Map<String, int> totals;
  final Map<String, int> tripCounts;
  DailyEarnings forCurrency(String code) => DailyEarnings(
    day: day,
    currency: code,
    totalMinor: totals[code] ?? (code == currency ? totalMinor : 0),
    trips: tripCounts[code] ?? (code == currency ? trips : 0),
  );
  final DateTime day;
  final int totalMinor;
  final int trips;
  @override
  List<Object> get props => [
    day,
    totalMinor,
    trips,
    currency,
    totals,
    tripCounts,
  ];
}
