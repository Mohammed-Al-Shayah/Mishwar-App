import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/get_week_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart';

class EarningsScreenState extends Equatable {
  const EarningsScreenState({
    this.days = const [],
    this.selected,
    this.trips = const [],
    this.loading = true,
    this.loadingTrips = false,
    this.failure,
  });
  final List<DailyEarnings> days;
  final DateTime? selected;
  final List<RideEntity> trips;
  final bool loading;
  final bool loadingTrips;
  final Failure? failure;
  DailyEarnings? get selectedEarnings =>
      days.where((day) => day.day == selected).firstOrNull;
  @override
  List<Object?> get props => [
    days,
    selected,
    trips,
    loading,
    loadingTrips,
    failure,
  ];
}

@injectable
class EarningsScreenCubit extends Cubit<EarningsScreenState> {
  EarningsScreenCubit(this._week, this._watch, this._history)
    : super(const EarningsScreenState());
  final GetWeekEarnings _week;
  final WatchDayEarnings _watch;
  final GetRideHistory _history;
  String? _uid;
  StreamSubscription<dynamic>? _subscription;
  int _generation = 0;
  Future<void> load(String uid, {DateTime? endingOn}) async {
    _uid = uid;
    final generation = ++_generation;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(const EarningsScreenState());
    final day = calendarDay(endingOn ?? ammanDay(DateTime.now()));
    final result = await _week(uid, day);
    if (isClosed || generation != _generation) return;
    await result.fold(
      (failure) async =>
          emit(EarningsScreenState(loading: false, failure: failure)),
      (days) async {
        emit(
          EarningsScreenState(
            days: List.unmodifiable(days),
            selected: day,
            loading: false,
          ),
        );
        await selectDay(day);
      },
    );
  }

  Future<void> selectDay(DateTime day) async {
    if (_uid == null || !state.days.any((value) => value.day == day)) return;
    final generation = ++_generation;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(
      EarningsScreenState(
        days: state.days,
        selected: day,
        loading: false,
        loadingTrips: true,
      ),
    );
    _subscription = _watch(_uid!, day).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) => _update(failure: failure),
        (value) => _update(
          days: List.unmodifiable(
            state.days.map((d) => d.day == day ? value : d),
          ),
        ),
      );
    });
    // Completion may cross midnight: traverse history and filter by completion.
    final trips = <RideEntity>[];
    HistoryCursor? cursor;
    do {
      final result = await _history(
        party: RideParty.driver,
        uid: _uid!,
        after: cursor,
      );
      if (isClosed || generation != _generation) return;
      final failure = result.getLeft().toNullable();
      if (failure != null) {
        _update(loadingTrips: false, failure: failure);
        return;
      }
      final page = result.getRight().toNullable()!;
      trips.addAll(
        page.items.where(
          (ride) => ammanDay(ride.completedAt ?? ride.createdAt) == day,
        ),
      );
      cursor = page.next;
    } while (cursor != null);
    trips.sort(
      (a, b) => (b.completedAt ?? b.createdAt).compareTo(
        a.completedAt ?? a.createdAt,
      ),
    );
    _update(trips: List.unmodifiable(trips), loadingTrips: false);
  }

  void _update({
    List<DailyEarnings>? days,
    List<RideEntity>? trips,
    bool? loadingTrips,
    Failure? failure,
  }) => emit(
    EarningsScreenState(
      days: days ?? state.days,
      selected: state.selected,
      trips: trips ?? state.trips,
      loading: false,
      loadingTrips: loadingTrips ?? state.loadingTrips,
      failure: failure ?? state.failure,
    ),
  );
  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
