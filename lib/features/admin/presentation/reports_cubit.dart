import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_reports.dart';

class ReportsState extends Equatable {
  const ReportsState({
    this.days = 7,
    this.data,
    this.loading = false,
    this.failure,
  });
  final int days;
  final ReportData? data;
  final bool loading;
  final Failure? failure;
  @override
  List<Object?> get props => [days, data, loading, failure];
}

@injectable
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._load) : super(const ReportsState());
  final LoadReports _load;
  int _generation = 0;
  Future<void> load([int? days]) async {
    final range = days ?? state.days;
    if (![7, 30, 90].contains(range)) return;
    final generation = ++_generation;
    emit(ReportsState(days: range, loading: true));
    final result = await _load(range);
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(ReportsState(days: range, failure: f)),
      (data) => emit(ReportsState(days: range, data: data)),
    );
  }
}
