import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';

enum HistoryStatus { loading, loaded, empty, failure }

class RideHistoryState extends Equatable {
  const RideHistoryState({
    this.status = HistoryStatus.loading,
    this.items = const [],
    this.hasMore = false,
    this.loadingMore = false,
    this.failure,
  });
  final HistoryStatus status;
  final List<RideEntity> items;
  final bool hasMore;
  final bool loadingMore;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, hasMore, loadingMore, failure];
}

@injectable
class RideHistoryCubit extends Cubit<RideHistoryState> {
  RideHistoryCubit(this._history) : super(const RideHistoryState());
  final GetRideHistory _history;
  String? _uid;
  HistoryCursor? _cursor;
  int _generation = 0;
  Future<void> loadFirst(String uid) async {
    _uid = uid;
    _cursor = null;
    final generation = ++_generation;
    emit(const RideHistoryState());
    final result = await _history(party: RideParty.rider, uid: uid);
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => emit(
        RideHistoryState(status: HistoryStatus.failure, failure: failure),
      ),
      (page) {
        _cursor = page.next;
        emit(
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
    if (_uid != null) await loadFirst(_uid!);
  }

  Future<void> loadMore() async {
    if (_uid == null || !state.hasMore || state.loadingMore) return;
    final previous = state;
    final generation = _generation;
    emit(
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
      (failure) => emit(
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
        emit(
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
