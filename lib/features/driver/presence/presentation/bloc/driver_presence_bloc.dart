import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/usecases/check_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_app_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/request_location_permission.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/register_push_token.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/go_offline.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/go_online.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/update_driver_location.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/presence_scheduler.dart';

sealed class DriverPresenceEvent {
  const DriverPresenceEvent();
}

class Started extends DriverPresenceEvent {
  const Started({
    required this.uid,
    required this.notificationTitle,
    required this.notificationText,
  });
  final String uid;
  final String notificationTitle;
  final String notificationText;
}

class GoOnlinePressed extends DriverPresenceEvent {
  const GoOnlinePressed();
}

class GoOfflinePressed extends DriverPresenceEvent {
  const GoOfflinePressed();
}

class _FixReceived extends DriverPresenceEvent {
  const _FixReceived(this.fix);
  final DriverFix fix;
}

class _Tick extends DriverPresenceEvent {
  const _Tick();
}

class _DriverChanged extends DriverPresenceEvent {
  const _DriverChanged(this.driver);
  final DriverEntity? driver;
}

class _Failed extends DriverPresenceEvent {
  const _Failed(this.failure);
  final Failure failure;
}

enum PresenceStatus {
  offline,
  goingOnline,
  online,
  goingOffline,
  permissionDenied,
  failure,
}

class DriverPresenceState extends Equatable {
  const DriverPresenceState({
    this.status = PresenceStatus.offline,
    this.isOnline = false,
    this.canGoOffline = true,
    this.lastFix,
    this.lastSentAt,
    this.failure,
  });
  final PresenceStatus status;
  final bool isOnline;
  final bool canGoOffline;
  final DriverFix? lastFix;
  final DateTime? lastSentAt;
  final Failure? failure;
  bool get busy =>
      status == PresenceStatus.goingOnline ||
      status == PresenceStatus.goingOffline;
  @override
  List<Object?> get props => [
    status,
    isOnline,
    canGoOffline,
    lastFix,
    lastSentAt,
    failure,
  ];
}

@injectable
class DriverPresenceBloc
    extends Bloc<DriverPresenceEvent, DriverPresenceState> {
  DriverPresenceBloc(
    this._watchDriver,
    this._checkPermission,
    this._requestPermission,
    this._currentPosition,
    this._goOnline,
    this._goOffline,
    this._update,
    this._watchLocation,
    this._settings,
    this._scheduler,
    this._registerPushToken,
  ) : super(const DriverPresenceState()) {
    // One queue for all event types prevents heartbeat/toggle writes from racing.
    on<DriverPresenceEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  static const interval = Duration(seconds: 5);
  final WatchDriver _watchDriver;
  final CheckLocationPermission _checkPermission;
  final RequestLocationPermission _requestPermission;
  final CurrentPosition _currentPosition;
  final GoOnline _goOnline;
  final GoOffline _goOffline;
  final UpdateDriverLocation _update;
  final WatchDriverLocation _watchLocation;
  final OpenAppSettings _settings;
  final PresenceScheduler _scheduler;
  StreamSubscription<dynamic>? _driverSubscription;
  // Cancelled by _stop on offline, failure, and close.
  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _fixSubscription;
  Timer? _timer;
  Started? _configuration;
  DriverEntity? _driver;
  DriverFix? _latest;
  DateTime? _lastSent;
  bool _closing = false;
  bool _tickQueued = false;
  bool _intentOnline = false;
  bool _pushRequested = false;
  final RegisterPushToken _registerPushToken;

  Future<void> openSettings() => _settings();
  void _add(DriverPresenceEvent event) {
    if (!_closing && !isClosed) add(event);
  }

  DriverPresenceState _state(
    PresenceStatus status, {
    bool? online,
    Failure? failure,
  }) => DriverPresenceState(
    status: status,
    isOnline: online ?? state.isOnline,
    canGoOffline: _driver?.currentRideId == null,
    lastFix: _latest,
    lastSentAt: _lastSent,
    failure: failure,
  );
  Future<void> _stop() async {
    _timer?.cancel();
    _timer = null;
    _tickQueued = false;
    final subscription = _fixSubscription;
    _fixSubscription = null;
    await subscription?.cancel();
  }

  void _track() {
    final config = _configuration;
    if (config == null || _closing || _fixSubscription != null) return;
    _fixSubscription =
        _watchLocation(
          notificationTitle: config.notificationTitle,
          notificationText: config.notificationText,
        ).listen(
          (result) => result.fold(
            (f) => _add(_Failed(f)),
            (fix) => _add(_FixReceived(fix)),
          ),
          onError: (Object _) =>
              _add(const _Failed(LocationFailure(LocationFailureCode.unknown))),
        );
    _timer = _scheduler.every(interval, () {
      if (!_tickQueued && !_closing) {
        _tickQueued = true;
        _add(const _Tick());
      }
    });
  }

  Future<void> _activate(
    Emitter<DriverPresenceState> emit, {
    required bool resume,
  }) async {
    emit(_state(PresenceStatus.goingOnline, online: resume));
    var permission = await _checkPermission();
    if (_closing) return;
    if (permission.getRight().toNullable() == LocationPermissionStatus.denied) {
      permission = await _requestPermission();
    }
    if (_closing) return;
    final permissionFailure = permission.getLeft().toNullable();
    if (permissionFailure != null) {
      emit(_state(PresenceStatus.failure, failure: permissionFailure));
      return;
    }
    if (permission.getRight().toNullable() ==
        LocationPermissionStatus.serviceDisabled) {
      emit(
        _state(
          PresenceStatus.failure,
          failure: const LocationFailure(LocationFailureCode.serviceDisabled),
        ),
      );
      return;
    }
    if (permission.getRight().toNullable() !=
        LocationPermissionStatus.granted) {
      emit(_state(PresenceStatus.permissionDenied));
      return;
    }
    final position = await _currentPosition();
    if (_closing) return;
    final locationFailure = position.getLeft().toNullable();
    if (locationFailure != null) {
      emit(_state(PresenceStatus.failure, failure: locationFailure));
      return;
    }
    _latest = DriverFix(position.getRight().toNullable()!);
    if (!resume) {
      final result = await _goOnline(_latest!.point);
      if (_closing) return;
      final failure = result.getLeft().toNullable();
      if (failure != null) {
        emit(_state(PresenceStatus.failure, failure: failure));
        return;
      }
    }
    _intentOnline = true;
    _lastSent = _scheduler.now();
    _track();
    emit(_state(PresenceStatus.online, online: true));
    if (!_pushRequested) {
      _pushRequested = true;
      await _registerPushToken(const NoParams());
    }
  }

  Future<void> _handle(
    DriverPresenceEvent event,
    Emitter<DriverPresenceState> emit,
  ) async {
    if (_closing) return;
    switch (event) {
      case Started():
        _configuration = event;
        await _driverSubscription?.cancel();
        if (_closing) return;
        _driverSubscription = _watchDriver(event.uid).listen(
          (r) =>
              r.fold((f) => _add(_Failed(f)), (d) => _add(_DriverChanged(d))),
        );
      case _DriverChanged(:final driver):
        _driver = driver;
        if (driver == null ||
            driver.status != DriverStatus.approved ||
            !driver.isOnline) {
          _intentOnline = false;
          await _stop();
          if (!_closing) emit(_state(PresenceStatus.offline, online: false));
        } else if (!_intentOnline) {
          _intentOnline = true;
          await _activate(emit, resume: true);
        } else {
          emit(_state(state.status, failure: state.failure));
        }
      case GoOnlinePressed():
        if (_configuration == null || state.busy || _fixSubscription != null) {
          return;
        }
        if (!state.isOnline && _driver?.canGoOnline != true) return;
        await _activate(emit, resume: state.isOnline);
      case GoOfflinePressed():
        if (!state.isOnline || !state.canGoOffline || state.busy) return;
        emit(_state(PresenceStatus.goingOffline));
        await _stop();
        if (_closing) return;
        final result = await _goOffline();
        if (_closing) return;
        final failure = result.getLeft().toNullable();
        if (failure != null) {
          _track();
          emit(_state(PresenceStatus.failure, failure: failure));
        } else {
          _intentOnline = false;
          emit(_state(PresenceStatus.offline, online: false));
        }
      case _FixReceived(:final fix):
        if (_fixSubscription == null) return;
        _latest = fix;
        emit(_state(state.status, failure: state.failure));
      case _Tick():
        _tickQueued = false;
        final fix = _latest;
        if (_timer == null || !state.isOnline || fix == null) return;
        final now = _scheduler.now();
        if (_lastSent != null && now.difference(_lastSent!) < interval) return;
        // Reserve the interval before awaiting, even if the network fails.
        _lastSent = now;
        final result = await _update(fix.point, heading: fix.heading);
        if (_closing) return;
        final failure = result.getLeft().toNullable();
        emit(
          _state(
            failure == null ? PresenceStatus.online : PresenceStatus.failure,
            failure: failure,
          ),
        );
      case _Failed(:final failure):
        await _stop();
        if (!_closing) emit(_state(PresenceStatus.failure, failure: failure));
    }
  }

  @override
  Future<void> close() async {
    _closing = true;
    await _stop();
    await _driverSubscription?.cancel();
    return super.close();
  }
}
