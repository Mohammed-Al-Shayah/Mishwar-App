import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart';

class DriverEarningsState extends Equatable {
  const DriverEarningsState({this.earnings, this.failure});
  final DailyEarnings? earnings;
  final Failure? failure;
  @override
  List<Object?> get props => [earnings, failure];
}

/// Home subscription, refreshed at Amman midnight.
@injectable
class DriverEarningsCubit extends Cubit<DriverEarningsState> {
  DriverEarningsCubit(this._watch) : super(const DriverEarningsState());
  final WatchDayEarnings _watch;
  StreamSubscription<dynamic>? _subscription;
  Timer? _midnight;
  Future<void> start(String uid) async {
    _midnight?.cancel();
    await _subscription?.cancel();
    if (isClosed) return;
    final now = DateTime.now().toUtc();
    final day = ammanDay(now);
    emit(const DriverEarningsState());
    _subscription = _watch(uid, day).listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => emit(DriverEarningsState(failure: failure)),
        (value) => emit(DriverEarningsState(earnings: value)),
      );
    });
    final nextMidnight = ammanDayStartUtc(day.add(const Duration(days: 1)));
    _midnight = Timer(
      nextMidnight.difference(now),
      () => unawaited(start(uid)),
    );
  }

  @override
  Future<void> close() async {
    _midnight?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
