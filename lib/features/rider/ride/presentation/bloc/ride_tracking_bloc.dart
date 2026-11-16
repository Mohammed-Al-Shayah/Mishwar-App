import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/geo/trip_motion.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_clock.dart';

sealed class RideTrackingEvent {
  const RideTrackingEvent();
}

class RideTrackingStarted extends RideTrackingEvent {
  const RideTrackingStarted();
}

class RideCancelRequested extends RideTrackingEvent {
  const RideCancelRequested();
}

class RideRetryRequested extends RideTrackingEvent {
  const RideRetryRequested();
}

class RideBackRequested extends RideTrackingEvent {
  const RideBackRequested();
}

class RideSubtitleTicked extends RideTrackingEvent {
  const RideSubtitleTicked();
}

class _RideChanged extends RideTrackingEvent {
  const _RideChanged(this.ride);
  final RideEntity ride;
}

class _RideFailed extends RideTrackingEvent {
  const _RideFailed(this.failure);
  final Failure failure;
}

class _LocationChanged extends RideTrackingEvent {
  const _LocationChanged(this.location, this.driverId);
  final DriverLiveLocation location;
  final String? driverId;
}

class _ClockTicked extends RideTrackingEvent {
  const _ClockTicked();
}

class _NoticeExpired extends RideTrackingEvent {
  const _NoticeExpired();
}

enum RideNavigation { home, confirm, summary }

class RideTrackingState extends Equatable {
  const RideTrackingState({
    this.ride,
    this.failure,
    this.isCancelling = false,
    this.subtitleIndex = 0,
    this.navigation,
    this.driverLocation,
    this.etaMinutes = 1,
    this.redispatchNotice = false,
    this.now,
  });
  final DriverLiveLocation? driverLocation;
  final int etaMinutes;
  final bool redispatchNotice;
  final DateTime? now;
  DateTime? get waitingSince => ride?.arrivedAt;
  RideTrackingState copyWith({
    RideEntity? ride,
    Failure? failure,
    bool? isCancelling,
    int? subtitleIndex,
    RideNavigation? navigation,
    DriverLiveLocation? driverLocation,
    int? etaMinutes,
    bool? redispatchNotice,
    DateTime? now,
    bool clearLocation = false,
  }) => RideTrackingState(
    ride: ride ?? this.ride,
    failure: failure,
    isCancelling: isCancelling ?? this.isCancelling,
    subtitleIndex: subtitleIndex ?? this.subtitleIndex,
    navigation: navigation,
    driverLocation: clearLocation
        ? null
        : driverLocation ?? this.driverLocation,
    etaMinutes: etaMinutes ?? this.etaMinutes,
    redispatchNotice: redispatchNotice ?? this.redispatchNotice,
    now: now ?? this.now,
  );
  final RideEntity? ride;
  final Failure? failure;
  final bool isCancelling;
  final int subtitleIndex;
  final RideNavigation? navigation;
  RideDraft? get retryDraft => ride?.draft;
  @override
  List<Object?> get props => [
    ride,
    failure,
    isCancelling,
    subtitleIndex,
    navigation,
    driverLocation,
    etaMinutes,
    redispatchNotice,
    now,
  ];
}

@injectable
class RideTrackingBloc extends Bloc<RideTrackingEvent, RideTrackingState> {
  RideTrackingBloc(
    this._watchRide,
    this._cancelRide,
    @factoryParam this.rideId,
    this._watchDriverLocation,
    this._clockSource,
  ) : super(const RideTrackingState()) {
    on<RideTrackingStarted>((event, emit) async {
      await _subscription?.cancel();
      if (isClosed) return;
      _subscription = _watchRide(rideId).listen(
        (result) => result.fold(
          (failure) {
            if (!isClosed) add(_RideFailed(failure));
          },
          (ride) {
            if (!isClosed) add(_RideChanged(ride));
          },
        ),
      );
    });
    on<_LocationChanged>((event, emit) {
      if (!_live(state.ride?.status) ||
          event.driverId != state.ride?.driverId) {
        return;
      }
      // The live document survives re-dispatch; ignore the previous assignment.
      final acceptedAt = state.ride?.acceptedAt;
      if (acceptedAt != null && event.location.updatedAt.isBefore(acceptedAt)) {
        return;
      }
      if (state.driverLocation != null &&
          event.location.updatedAt.isBefore(state.driverLocation!.updatedAt)) {
        return;
      }
      emit(
        state.copyWith(
          driverLocation: event.location,
          etaMinutes: _eta(state.ride!, event.location),
        ),
      );
    });
    on<_ClockTicked>((event, emit) {
      final ride = state.ride;
      if (ride != null && _live(ride.status)) {
        emit(
          state.copyWith(
            now: _clockSource.now(),
            etaMinutes: _eta(ride, state.driverLocation),
          ),
        );
      }
    });
    on<_NoticeExpired>(
      (event, emit) => emit(state.copyWith(redispatchNotice: false)),
    );
    on<_RideChanged>((event, emit) {
      final ride = event.ride;
      final redispatched =
          ride.status == RideStatus.searching && _live(state.ride?.status);
      final changedDriver = ride.driverId != state.ride?.driverId;
      if (!_live(ride.status) || changedDriver) {
        unawaited(_locationSubscription?.cancel());
        _locationSubscription = null;
        _clock?.cancel();
        _clock = null;
      }
      if (_live(ride.status) && _locationSubscription == null) {
        final driverId = ride.driverId;
        _locationSubscription = _watchDriverLocation(rideId).listen((result) {
          result.fold((_) {}, (location) {
            if (!isClosed) add(_LocationChanged(location, driverId));
          });
        });
        _clock = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!isClosed) add(const _ClockTicked());
        });
      }
      if (redispatched) {
        _notice?.cancel();
        _notice = Timer(const Duration(seconds: 4), () {
          if (!isClosed) add(const _NoticeExpired());
        });
      } else if (ride.status != RideStatus.searching) {
        _notice?.cancel();
      }
      emit(
        state.copyWith(
          ride: event.ride,
          clearLocation: changedDriver || !_live(ride.status),
          redispatchNotice:
              redispatched ||
              (ride.status == RideStatus.searching && state.redispatchNotice),
          etaMinutes: _eta(ride, changedDriver ? null : state.driverLocation),
          subtitleIndex: state.subtitleIndex,
          isCancelling:
              state.isCancelling && event.ride.status != RideStatus.cancelled,
          navigation: event.ride.status == RideStatus.cancelled
              ? RideNavigation.home
              : event.ride.status == RideStatus.completed
              ? RideNavigation.summary
              : null,
        ),
      );
    });
    on<_RideFailed>(
      (event, emit) => emit(state.copyWith(failure: event.failure)),
    );
    on<RideSubtitleTicked>((event, emit) {
      if (state.ride?.status == RideStatus.searching) {
        emit(
          state.copyWith(
            ride: state.ride,
            failure: state.failure,
            isCancelling: state.isCancelling,
            subtitleIndex: (state.subtitleIndex + 1) % 3,
          ),
        );
      }
    });
    on<RideCancelRequested>((event, emit) async {
      final ride = state.ride;
      if (state.isCancelling ||
          ride == null ||
          ![
            RideStatus.searching,
            RideStatus.accepted,
            RideStatus.arriving,
            RideStatus.arrived,
          ].contains(ride.status)) {
        return;
      }
      emit(
        state.copyWith(
          ride: ride,
          isCancelling: true,
          subtitleIndex: state.subtitleIndex,
        ),
      );
      final result = await _cancelRide(rideId);
      if (isClosed || state.navigation != null) return;
      // The snapshot, rather than the callable completion, drives navigation.
      emit(
        state.copyWith(
          ride: state.ride,
          subtitleIndex: state.subtitleIndex,
          failure: result.getLeft().toNullable(),
          isCancelling: false,
        ),
      );
    });
    on<RideRetryRequested>((event, emit) {
      if (state.ride?.status == RideStatus.noDrivers) {
        emit(
          RideTrackingState(
            ride: state.ride,
            navigation: RideNavigation.confirm,
          ),
        );
      }
    });
    on<RideBackRequested>(
      (event, emit) => emit(
        RideTrackingState(ride: state.ride, navigation: RideNavigation.home),
      ),
    );
  }
  static bool _live(RideStatus? status) => [
    RideStatus.accepted,
    RideStatus.arriving,
    RideStatus.arrived,
    RideStatus.inProgress,
  ].contains(status);
  int _eta(RideEntity ride, DriverLiveLocation? location) {
    if (ride.status == RideStatus.inProgress) {
      final elapsed = ride.startedAt == null
          ? 0
          : _clockSource.now().difference(ride.startedAt!).inSeconds;
      return math.max(
        1,
        (((ride.route?.durationSeconds ?? 60) - elapsed) / 60).ceil(),
      );
    }
    return location == null
        ? 1
        : math.max(
            1,
            (distanceMeters(location.point, ride.pickup.location) / 400).ceil(),
          );
  }

  final RideTrackingClock _clockSource;
  final WatchDriverLocation _watchDriverLocation;
  StreamSubscription<dynamic>? _locationSubscription;
  Timer? _clock;
  Timer? _notice;
  final WatchRide _watchRide;
  final CancelRide _cancelRide;
  final String rideId;
  StreamSubscription<dynamic>? _subscription;
  @override
  Future<void> close() async {
    _clock?.cancel();
    _notice?.cancel();
    await _locationSubscription?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
