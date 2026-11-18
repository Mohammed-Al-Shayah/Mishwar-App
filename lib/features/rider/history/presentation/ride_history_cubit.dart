import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_scheduled_rides.dart';

enum HistoryStatus { loading, loaded, empty, failure }

class RideHistoryState extends Equatable {
  const RideHistoryState({
    this.scheduled = const [],
    this.scheduledFailure,
    this.cancellingId,
    this.status = HistoryStatus.loading,
    this.items = const [],
    this.hasMore = false,
    this.loadingMore = false,
    this.failure,
  });
  final List<RideEntity> scheduled;
  final Failure? scheduledFailure;
  final String? cancellingId;
  RideHistoryState withScheduled(
    List<RideEntity> rides,
    Failure? error,
    String? cancelling,
  ) => RideHistoryState(
    status: status,
    items: items,
    hasMore: hasMore,
    loadingMore: loadingMore,
    failure: failure,
    scheduled: rides,
    scheduledFailure: error,
    cancellingId: cancelling,
  );
  final HistoryStatus status;
  final List<RideEntity> items;
  final bool hasMore;
  final bool loadingMore;
  final Failure? failure;
  @override
  List<Object?> get props => [
    status,
    items,
    hasMore,
    loadingMore,
    failure,
    scheduled,
    scheduledFailure,
    cancellingId,
  ];
}

@injectable
class RideHistoryCubit extends Cubit<RideHistoryState> {
  RideHistoryCubit(
    this._history, {
    required this.watchScheduledRides,
    required this.cancelRide,
  }) : super(const RideHistoryState());
  final WatchScheduledRides watchScheduledRides;
  final CancelRide cancelRide;
  StreamSubscription<Either<Failure, List<RideEntity>>>? _scheduledSubscription;
  void _emitHistory(RideHistoryState next) => emit(
    next.withScheduled(
      state.scheduled,
      state.scheduledFailure,
      state.cancellingId,
    ),
  );
  Future<void> cancelScheduled(String id) async {
    if (state.cancellingId != null) return;
    emit(state.withScheduled(state.scheduled, null, id));
    final result = await cancelRide(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.withScheduled(state.scheduled, failure, null)),
      (_) => emit(
        state.withScheduled(
          List.unmodifiable(state.scheduled.where((ride) => ride.id != id)),
          null,
          null,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _scheduledSubscription?.cancel();
    return super.close();
  }

  final GetRideHistory _history;
  String? _uid;
  HistoryCursor? _cursor;
  int _generation = 0;
  Future<void> loadFirst(String uid) async {
    if (_uid != uid) {
      await _scheduledSubscription?.cancel();
      if (isClosed) return;
      _scheduledSubscription = watchScheduledRides(uid).listen((result) {
        if (isClosed) return;
        result.fold(
          (failure) => emit(
            state.withScheduled(state.scheduled, failure, state.cancellingId),
          ),
          (rides) => emit(
            state.withScheduled(
              List.unmodifiable(rides),
              null,
              state.cancellingId,
            ),
          ),
        );
      });
    }
    _uid = uid;
    _cursor = null;
    final generation = ++_generation;
    _emitHistory(const RideHistoryState());
    final result = await _history(party: RideParty.rider, uid: uid);
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => _emitHistory(
        RideHistoryState(status: HistoryStatus.failure, failure: failure),
      ),
      (page) {
        _cursor = page.next;
        _emitHistory(
          RideHistoryState(
            status: page.items.isEmpty
                ? HistoryStatus.empty
                : HistoryStatus.loaded,
            items: page.items,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid != null) {
      if (state.scheduledFailure != null) _uid = null;
      await loadFirst(uid);
    }
  }

  Future<void> loadMore() async {
    if (_uid == null || !state.hasMore || state.loadingMore) return;
    final previous = state;
    final generation = _generation;
    _emitHistory(
      RideHistoryState(
        status: HistoryStatus.loaded,
        items: previous.items,
        hasMore: true,
        loadingMore: true,
      ),
    );
    final result = await _history(
      party: RideParty.rider,
      uid: _uid!,
      after: _cursor,
    );
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => _emitHistory(
        RideHistoryState(
          status: HistoryStatus.loaded,
          items: previous.items,
          hasMore: true,
          failure: failure,
        ),
      ),
      (page) {
        _cursor = page.next;
        final items = {
          for (final item in [...previous.items, ...page.items]) item.id: item,
        }.values.toList();
        _emitHistory(
          RideHistoryState(
            status: HistoryStatus.loaded,
            items: List.unmodifiable(items),
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }
}
