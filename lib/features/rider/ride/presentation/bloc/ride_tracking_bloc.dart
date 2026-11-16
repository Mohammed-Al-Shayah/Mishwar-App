import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';

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

enum RideNavigation { home, confirm }

class RideTrackingState extends Equatable {
  const RideTrackingState({
    this.ride,
    this.failure,
    this.isCancelling = false,
    this.subtitleIndex = 0,
    this.navigation,
  });
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
  ];
}

@injectable
class RideTrackingBloc extends Bloc<RideTrackingEvent, RideTrackingState> {
  RideTrackingBloc(this._watchRide, this._cancelRide, @factoryParam this.rideId)
    : super(const RideTrackingState()) {
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
    on<_RideChanged>((event, emit) {
      emit(
        RideTrackingState(
          ride: event.ride,
          subtitleIndex: state.subtitleIndex,
          isCancelling:
              state.isCancelling && event.ride.status != RideStatus.cancelled,
          navigation: event.ride.status == RideStatus.cancelled
              ? RideNavigation.home
              : null,
        ),
      );
    });
    on<_RideFailed>(
      (event, emit) =>
          emit(RideTrackingState(ride: state.ride, failure: event.failure)),
    );
    on<RideSubtitleTicked>((event, emit) {
      if (state.ride?.status == RideStatus.searching) {
        emit(
          RideTrackingState(
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
        RideTrackingState(
          ride: ride,
          isCancelling: true,
          subtitleIndex: state.subtitleIndex,
        ),
      );
      final result = await _cancelRide(rideId);
      if (isClosed || state.navigation != null) return;
      // The snapshot, rather than the callable completion, drives navigation.
      emit(
        RideTrackingState(
          ride: state.ride,
          subtitleIndex: state.subtitleIndex,
          failure: result.getLeft().toNullable(),
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
  final WatchRide _watchRide;
  final CancelRide _cancelRide;
  final String rideId;
  StreamSubscription<dynamic>? _subscription;
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
