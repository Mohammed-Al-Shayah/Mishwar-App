import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/usecases/check_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_app_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_location_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/request_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/watch_position.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_state.dart';

@injectable
class RiderHomeCubit extends Cubit<RiderHomeState> {
  RiderHomeCubit(
    this._check,
    this._request,
    this._current,
    this._watch,
    this._appSettings,
    this._locationSettings,
  ) : super(const RiderHomeState());
  final CheckLocationPermission _check;
  final RequestLocationPermission _request;
  final CurrentPosition _current;
  final WatchPosition _watch;
  final OpenAppSettings _appSettings;
  final OpenLocationSettings _locationSettings;
  StreamSubscription<Either<Failure, GeoPointValue>>? _subscription;
  bool _busy = false;
  Future<void> start() async {
    if (_busy || isClosed) return;
    _busy = true;
    emit(
      RiderHomeState(
        permission: state.permission,
        position: state.position,
        isLocating: true,
      ),
    );
    await _subscription?.cancel();
    _subscription = null;
    if (isClosed) {
      _busy = false;
      return;
    }
    var result = await _check();
    if (isClosed) {
      _busy = false;
      return;
    }
    if (result.getRight().toNullable() == LocationPermissionStatus.denied) {
      result = await _request();
    }
    if (isClosed) {
      _busy = false;
      return;
    }
    await result.fold(
      (failure) async {
        _fail(failure);
      },
      (permission) async {
        emit(
          RiderHomeState(
            permission: permission,
            position: state.position,
            isLocating: permission == LocationPermissionStatus.granted,
          ),
        );
        if (permission != LocationPermissionStatus.granted) return;
        final position = await _current();
        if (isClosed) return;
        position.fold(_fail, _position);
        // Keep listening even if the initial fix times out.
        _subscription = _watch().listen((result) {
          if (isClosed) return;
          result.fold(_fail, _position);
        });
      },
    );
    _busy = false;
  }

  void _position(GeoPointValue position) {
    if (!isClosed) {
      emit(
        RiderHomeState(
          permission: LocationPermissionStatus.granted,
          position: position,
        ),
      );
    }
  }

  void _fail(Failure failure) {
    if (isClosed) return;
    final permission = switch (failure) {
      LocationFailure(code: LocationFailureCode.permissionDenied) =>
        LocationPermissionStatus.denied,
      LocationFailure(code: LocationFailureCode.serviceDisabled) =>
        LocationPermissionStatus.serviceDisabled,
      _ => state.permission,
    };
    emit(
      RiderHomeState(
        permission: permission,
        position: state.position,
        failure: failure,
      ),
    );
  }

  Future<void> openAppSettings() => _open(_appSettings.call);
  Future<void> openLocationSettings() => _open(_locationSettings.call);
  Future<void> _open(Future<void> Function() action) async {
    try {
      await action();
    } on Exception {
      _fail(const LocationFailure(LocationFailureCode.unknown));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
