import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/update_ride_status.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';

/// Injectable wall clock and ticker, including when using fakeAsync.
@lazySingleton
class TripTicker {
  DateTime now() => DateTime.now();
  Timer everySecond(void Function() callback) =>
      Timer.periodic(const Duration(seconds: 1), (_) => callback());
}

sealed class DriverTripEvent {
  const DriverTripEvent();
}

final class Started extends DriverTripEvent {
  const Started();
}

final class ArrivedPressed extends DriverTripEvent {
  const ArrivedPressed();
}

final class RetryPressed extends DriverTripEvent {
  const RetryPressed();
}

final class StartPressed extends DriverTripEvent {
  const StartPressed();
}

final class CompletePressed extends DriverTripEvent {
  const CompletePressed({this.deliveryCode});
  final String? deliveryCode;
}

final class CancelPressed extends DriverTripEvent {
  const CancelPressed();
}

final class CashCollectedPressed extends DriverTripEvent {
  const CashCollectedPressed();
}

final class _RideChanged extends DriverTripEvent {
  const _RideChanged(this.ride);
  final RideEntity ride;
}

final class _Failed extends DriverTripEvent {
  const _Failed(this.failure);
  final Failure failure;
}

final class _Tick extends DriverTripEvent {
  const _Tick();
}

enum TripPhase {
  toPickup,
  waiting,
  onTrip,
  collectCash,
  done,
  cancelled,
  redispatched,
}

class DriverTripState extends Equatable {
  const DriverTripState({
    this.ride,
    this.phase = TripPhase.toPickup,
    this.busy = false,
    this.failure,
    this.waitingElapsed = Duration.zero,
  });
  final RideEntity? ride;
  final TripPhase phase;
  final bool busy;
  final Failure? failure;
  final Duration waitingElapsed;
  bool get terminal => const [
    TripPhase.done,
    TripPhase.cancelled,
    TripPhase.redispatched,
  ].contains(phase);
  @override
  List<Object?> get props => [ride, phase, busy, failure, waitingElapsed];
}

@injectable
class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  DriverTripBloc(
    @factoryParam this.rideId,
    this._watch,
    this._update,
    this._cancel,
    this._ticker,
  ) : super(const DriverTripState()) {
    on<DriverTripEvent>(_handle);
  }
  final String rideId;
  final WatchRide _watch;
  final UpdateRideStatus _update;
  final CancelRide _cancel;
  final TripTicker _ticker;
  StreamSubscription<dynamic>? _subscription;
  Timer? _timer;
  bool _first = true;
  bool _operation = false;
  bool _cancelIntent = false;
  bool _closing = false;
  RideStatus? _pending;

  void _add(DriverTripEvent event) {
    if (!_closing && !isClosed) add(event);
  }

  Duration _elapsed(RideEntity? ride) {
    final arrived = ride?.arrivedAt;
    if (arrived == null) return Duration.zero;
    final elapsed = _ticker.now().difference(arrived);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  DriverTripState _state({
    RideEntity? ride,
    TripPhase? phase,
    bool? busy,
    Failure? failure,
  }) => DriverTripState(
    ride: ride ?? state.ride,
    phase: phase ?? state.phase,
    busy: busy ?? (_operation || _pending != null),
    failure: failure,
    waitingElapsed: (phase ?? state.phase) == TripPhase.waiting
        ? _elapsed(ride ?? state.ride)
        : Duration.zero,
  );
  Future<void> _transition(
    RideStatus target,
    Emitter<DriverTripState> emit, {
    String? deliveryCode,
  }) async {
    if (_operation || _pending != null || state.terminal) return;
    _operation = true;
    _pending = target;
    emit(_state());
    final result = deliveryCode == null
        ? await _update(rideId, target)
        : await _update(rideId, target, deliveryCode: deliveryCode);
    _operation = false;
    if (_closing || state.terminal) return;
    final failure = result.getLeft().toNullable();
    if (failure != null) _pending = null;
    // Reserve the button until the authoritative snapshot arrives.
    emit(_state(failure: failure));
  }

  Future<void> _handle(
    DriverTripEvent event,
    Emitter<DriverTripState> emit,
  ) async {
    if (_closing) return;
    switch (event) {
      case Started():
        if (_subscription != null) return;
        _subscription = _watch(rideId).listen(
          (result) => result.fold(
            (f) => _add(_Failed(f)),
            (r) => _add(_RideChanged(r)),
          ),
          onError: (Object _) =>
              _add(const _Failed(ServerFailure('ride-stream'))),
        );
      case _RideChanged(:final ride):
        if (state.terminal) return;
        final first = _first;
        _first = false;
        final phase = switch (ride.status) {
          RideStatus.accepted || RideStatus.arriving => TripPhase.toPickup,
          RideStatus.arrived => TripPhase.waiting,
          RideStatus.inProgress => TripPhase.onTrip,
          RideStatus.completed => TripPhase.collectCash,
          RideStatus.searching when _cancelIntent => TripPhase.redispatched,
          _ => TripPhase.cancelled,
        };
        if (ride.status == _pending || phase != state.phase) _pending = null;
        _timer?.cancel();
        _timer = phase == TripPhase.waiting
            ? _ticker.everySecond(() => _add(const _Tick()))
            : null;
        emit(
          _state(
            ride: ride,
            phase: phase,
            busy:
                !const [
                  TripPhase.cancelled,
                  TripPhase.redispatched,
                ].contains(phase) &&
                (_operation || _pending != null),
          ),
        );
        if (first && ride.status == RideStatus.accepted) {
          await _transition(RideStatus.arriving, emit);
        }
      case ArrivedPressed():
        if (state.ride?.status == RideStatus.arriving) {
          await _transition(RideStatus.arrived, emit);
        }
      case RetryPressed():
        if (state.ride?.status == RideStatus.accepted) {
          await _transition(RideStatus.arriving, emit);
        }
      case StartPressed():
        if (state.phase == TripPhase.waiting) {
          await _transition(RideStatus.inProgress, emit);
        }
      case CompletePressed(:final deliveryCode):
        if (state.phase == TripPhase.onTrip) {
          await _transition(
            RideStatus.completed,
            emit,
            deliveryCode: deliveryCode,
          );
        }
      case CancelPressed():
        if (state.busy ||
            state.ride == null ||
            !const [
              TripPhase.toPickup,
              TripPhase.waiting,
            ].contains(state.phase)) {
          return;
        }
        _operation = true;
        _cancelIntent = true;
        emit(_state());
        final result = await _cancel(rideId);
        _operation = false;
        if (_closing || state.terminal) return;
        result.fold(
          (f) {
            _cancelIntent = false;
            emit(_state(failure: f));
          },
          (r) {
            _timer?.cancel();
            emit(
              _state(
                phase: r.redispatched
                    ? TripPhase.redispatched
                    : TripPhase.cancelled,
                busy: false,
              ),
            );
          },
        );
      case CashCollectedPressed():
        if (state.phase == TripPhase.collectCash && !state.busy) {
          // TODO(T4.5): Insert the rider rating step before returning home.
          emit(_state(phase: TripPhase.done, busy: false));
        }
      case _Tick():
        if (state.phase == TripPhase.waiting) {
          emit(_state(failure: state.failure));
        }
      case _Failed(:final failure):
        if (!state.terminal) {
          _pending = null;
          emit(_state(failure: failure));
        }
    }
  }

  @override
  Future<void> close() async {
    _closing = true;
    _timer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
