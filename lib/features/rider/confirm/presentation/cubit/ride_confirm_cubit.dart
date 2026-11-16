import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/usecases/request_ride.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimate.dart';
import 'package:mishwar/features/common/route/domain/entities/route_info.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

sealed class RideConfirmState extends Equatable {
  const RideConfirmState();
  @override
  List<Object?> get props => [];
}

class RideConfirmLoading extends RideConfirmState {
  const RideConfirmLoading();
}

class RideConfirmLoaded extends RideConfirmState {
  RideConfirmLoaded({
    required this.route,
    required List<FareEstimate> fares,
    this.selected = VehicleType.economy,
    this.isRequesting = false,
    this.requestFailure,
  }) : fares = List.unmodifiable(fares);
  final RouteInfo route;
  final List<FareEstimate> fares;
  final VehicleType selected;
  final bool isRequesting;
  final Failure? requestFailure;
  int get fareFils =>
      fares.firstWhere((fare) => fare.vehicleType == selected).fils;
  @override
  List<Object?> get props => [
    route,
    fares,
    selected,
    isRequesting,
    requestFailure,
  ];
}

class RideConfirmFailure extends RideConfirmState {
  const RideConfirmFailure(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class RideConfirmRequested extends RideConfirmLoaded {
  RideConfirmRequested({
    required super.route,
    required super.fares,
    required super.selected,
    required this.rideId,
  });
  final String rideId;
  @override
  List<Object?> get props => [...super.props, rideId];
}

@injectable
class RideConfirmCubit extends Cubit<RideConfirmState> {
  RideConfirmCubit(
    this._getFareEstimates,
    this._requestRide,
    @factoryParam this.draft,
  ) : super(const RideConfirmLoading());
  final GetFareEstimates _getFareEstimates;
  final RequestRide _requestRide;
  final RideDraft draft;
  bool _fetching = false;

  Future<void> start() async {
    if (_fetching || isClosed) return;
    _fetching = true;
    emit(const RideConfirmLoading());
    final result = await _getFareEstimates(
      origin: draft.pickup.location,
      destination: draft.dropoff.location,
    );
    _fetching = false;
    if (isClosed) return;
    result.fold(
      (failure) => emit(RideConfirmFailure(failure)),
      (estimates) => emit(
        RideConfirmLoaded(route: estimates.route, fares: estimates.fares),
      ),
    );
  }

  Future<void> retry() => start();

  void select(VehicleType vehicle) {
    final current = state;
    if (current is! RideConfirmLoaded ||
        current.isRequesting ||
        current is RideConfirmRequested) {
      return;
    }
    emit(
      RideConfirmLoaded(
        route: current.route,
        fares: current.fares,
        selected: vehicle,
      ),
    );
  }

  Future<void> confirm() async {
    final current = state;
    if (current is! RideConfirmLoaded ||
        current.isRequesting ||
        current is RideConfirmRequested) {
      return;
    }
    emit(
      RideConfirmLoaded(
        route: current.route,
        fares: current.fares,
        selected: current.selected,
        isRequesting: true,
      ),
    );
    final result = await _requestRide(draft, current.selected);
    if (isClosed) return;
    void requested(String id) => emit(
      RideConfirmRequested(
        route: current.route,
        fares: current.fares,
        selected: current.selected,
        rideId: id,
      ),
    );
    result.fold((failure) {
      if (failure is ActiveRideFailure) {
        requested(failure.activeRideId);
      } else {
        emit(
          RideConfirmLoaded(
            route: current.route,
            fares: current.fares,
            selected: current.selected,
            requestFailure: failure,
          ),
        );
      }
    }, requested);
  }
}
