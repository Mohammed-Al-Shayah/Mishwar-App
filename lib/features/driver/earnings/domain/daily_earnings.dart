import 'package:equatable/equatable.dart';

class DailyEarnings extends Equatable {
  const DailyEarnings({required this.day, this.totalFils = 0, this.trips = 0});
  final DateTime day;
  final int totalFils;
  final int trips;
  @override
  List<Object> get props => [day, totalFils, trips];
}
