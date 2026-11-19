import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_reports.dart';

class ReportsState extends Equatable {
  const ReportsState({
    this.days = 7,
    this.market = 'JO',
    this.data,
    this.loading = false,
    this.failure,
  });
  final String market;
  final int days;
  final ReportData? data;
  final bool loading;
  final Failure? failure;
  @override
  List<Object?> get props => [market, days, data, loading, failure];
}

@injectable
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._load) : super(const ReportsState());
  final LoadReports _load;
  int _generation = 0;
  Future<void> load([int? days, String? market]) async {
    final selectedMarket = market ?? state.market;
    final range = days ?? state.days;
    if (![7, 30, 90].contains(range)) return;
    final generation = ++_generation;
    emit(ReportsState(market: selectedMarket, days: range, loading: true));
    final result = await _load(range, selectedMarket);
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) =>
          emit(ReportsState(market: selectedMarket, days: range, failure: f)),
      (data) =>
          emit(ReportsState(market: selectedMarket, days: range, data: data)),
    );
  }
}
