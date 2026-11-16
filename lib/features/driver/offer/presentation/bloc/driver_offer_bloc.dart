import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/accept_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/decline_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';

@lazySingleton
class OfferScheduler {
  DateTime now() => DateTime.now();
  Timer every(Duration duration, void Function() callback) =>
      Timer.periodic(duration, (_) => callback());
  Timer after(Duration duration, void Function() callback) =>
      Timer(duration, callback);
}

sealed class DriverOfferEvent {
  const DriverOfferEvent();
}

final class Started extends DriverOfferEvent {
  const Started(this.uid);
  final String uid;
}

final class _OfferChanged extends DriverOfferEvent {
  const _OfferChanged(this.offer);
  final DriverOffer? offer;
}

final class _RideLoaded extends DriverOfferEvent {
  const _RideLoaded(this.offer, this.ride, this.failure);
  final DriverOffer offer;
  final RideEntity? ride;
  final Failure? failure;
}

final class _Tick extends DriverOfferEvent {
  const _Tick();
}

final class _Dismiss extends DriverOfferEvent {
  const _Dismiss(this.generation);
  final int generation;
}

final class AcceptPressed extends DriverOfferEvent {
  const AcceptPressed();
}

final class DeclinePressed extends DriverOfferEvent {
  const DeclinePressed();
}

enum OfferStatus {
  idle,
  loading,
  offered,
  accepting,
  declining,
  accepted,
  expired,
  lost,
}

class DriverOfferState extends Equatable {
  const DriverOfferState({
    this.status = OfferStatus.idle,
    this.ride,
    this.remaining = Duration.zero,
    this.total = const Duration(seconds: 15),
    this.failure,
  });
  final OfferStatus status;
  final RideEntity? ride;
  final Duration remaining;
  final Duration total;
  final Failure? failure;
  bool get showing =>
      ride != null &&
      status != OfferStatus.idle &&
      status != OfferStatus.accepted;
  bool get busy =>
      status == OfferStatus.accepting || status == OfferStatus.declining;
  @override
  List<Object?> get props => [status, ride, remaining, total, failure];
}

@injectable
class DriverOfferBloc extends Bloc<DriverOfferEvent, DriverOfferState> {
  DriverOfferBloc(
    this._watchDriver,
    this._watchRide,
    this._accept,
    this._decline,
    this._scheduler,
  ) : super(const DriverOfferState()) {
    on<Started>(_start);
    on<_OfferChanged>(_changed);
    on<_RideLoaded>(_loaded);
    on<_Tick>((event, emit) {
      if (state.status != OfferStatus.offered || _offer == null) return;
      final remaining = _remaining();
      if (remaining == Duration.zero) {
        _terminal(OfferStatus.expired, emit);
      } else {
        emit(
          DriverOfferState(
            status: OfferStatus.offered,
            ride: state.ride,
            remaining: remaining,
            failure: state.failure,
          ),
        );
      }
    });
    on<_Dismiss>((event, emit) {
      if (event.generation == _generation &&
          (state.status == OfferStatus.expired ||
              state.status == OfferStatus.lost)) {
        emit(const DriverOfferState());
      }
    });
    on<AcceptPressed>(_acceptPressed);
    on<DeclinePressed>(_declinePressed);
  }
  final WatchDriver _watchDriver;
  final WatchRide _watchRide;
  final AcceptRide _accept;
  final DeclineRide _decline;
  final OfferScheduler _scheduler;
  StreamSubscription<dynamic>? _driverSubscription;
  StreamSubscription<dynamic>? _rideSubscription;
  Timer? _ticker;
  Timer? _dismiss;
  DriverOffer? _offer;
  int _generation = 0;
  final Set<String> _handled = {};
  Duration _remaining() {
    final milliseconds = _offer!.expiresAt
        .difference(_scheduler.now())
        .inMilliseconds
        .clamp(0, 15000);
    return Duration(milliseconds: milliseconds);
  }

  Future<void> _start(Started event, Emitter<DriverOfferState> emit) async {
    await _driverSubscription?.cancel();
    _driverSubscription = _watchDriver(event.uid).listen(
      (result) =>
          result.fold((_) {}, (driver) => add(_OfferChanged(driver?.offer))),
    );
  }

  void _changed(
    _OfferChanged event,
    Emitter<DriverOfferState> emit,
  ) {
    final offer = event.offer;
    if (offer == _offer) return;
    // Acceptance can clear the offer before the callable returns.
    if (state.busy && (offer == null || offer.rideId == _offer?.rideId)) return;
    _generation++;
    _ticker?.cancel();
    _dismiss?.cancel();
    _offer = offer;
    unawaited(_rideSubscription?.cancel());
    _rideSubscription = null;
    emit(const DriverOfferState());
    if (offer == null ||
        !offer.expiresAt.isAfter(_scheduler.now()) ||
        !_handled.add('${offer.rideId}:${offer.seq}')) {
      return;
    }
    emit(const DriverOfferState(status: OfferStatus.loading));
    _rideSubscription = _watchRide(offer.rideId)
        .take(1)
        .listen(
          (result) => result.fold(
            (failure) => add(_RideLoaded(offer, null, failure)),
            (ride) => add(_RideLoaded(offer, ride, null)),
          ),
        );
  }

  void _loaded(_RideLoaded event, Emitter<DriverOfferState> emit) {
    if (event.offer != _offer) return;
    if (event.ride == null) {
      emit(const DriverOfferState());
      return;
    }
    emit(
      DriverOfferState(
        status: OfferStatus.offered,
        ride: event.ride,
        remaining: _remaining(),
      ),
    );
    if (_remaining() == Duration.zero) {
      _terminal(OfferStatus.expired, emit);
      return;
    }
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.alert));
    _ticker = _scheduler.every(
      const Duration(seconds: 1),
      () => add(const _Tick()),
    );
  }

  void _terminal(OfferStatus status, Emitter<DriverOfferState> emit) {
    _ticker?.cancel();
    emit(DriverOfferState(status: status, ride: state.ride));
    final generation = _generation;
    _dismiss?.cancel();
    _dismiss = _scheduler.after(
      const Duration(milliseconds: 1500),
      () => add(_Dismiss(generation)),
    );
  }

  Future<void> _acceptPressed(
    AcceptPressed event,
    Emitter<DriverOfferState> emit,
  ) async {
    if (state.status != OfferStatus.offered) return;
    final ride = state.ride!;
    final generation = _generation;
    emit(
      DriverOfferState(
        status: OfferStatus.accepting,
        ride: ride,
        remaining: _remaining(),
      ),
    );
    final result = await _accept(ride.id);
    if (generation != _generation) return;
    result.fold(
      (failure) {
        if (failure == const OfferFailure(OfferFailureReason.expired)) {
          _terminal(OfferStatus.lost, emit);
        } else if (_remaining() == Duration.zero) {
          _terminal(OfferStatus.expired, emit);
        } else {
          emit(
            DriverOfferState(
              status: OfferStatus.offered,
              ride: ride,
              remaining: _remaining(),
              failure: failure,
            ),
          );
        }
      },
      (_) {
        _ticker?.cancel();
        emit(DriverOfferState(status: OfferStatus.accepted, ride: ride));
      },
    );
  }

  Future<void> _declinePressed(
    DeclinePressed event,
    Emitter<DriverOfferState> emit,
  ) async {
    if (state.status != OfferStatus.offered) return;
    final ride = state.ride!;
    final generation = _generation;
    emit(
      DriverOfferState(
        status: OfferStatus.declining,
        ride: ride,
        remaining: _remaining(),
      ),
    );
    final result = await _decline(ride.id);
    if (generation != _generation) return;
    result.fold(
      (failure) {
        if (_remaining() == Duration.zero) {
          _terminal(OfferStatus.expired, emit);
        } else {
          emit(
            DriverOfferState(
              status: OfferStatus.offered,
              ride: ride,
              remaining: _remaining(),
              failure: failure,
            ),
          );
        }
      },
      (_) {
        _ticker?.cancel();
        emit(const DriverOfferState());
      },
    );
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    _dismiss?.cancel();
    await _driverSubscription?.cancel();
    await _rideSubscription?.cancel();
    return super.close();
  }
}
