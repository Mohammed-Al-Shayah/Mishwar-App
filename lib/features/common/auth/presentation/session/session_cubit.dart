import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';

@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._watchAuth, this._watchUser, this._watchDriver)
    : super(const SessionUnknown()) {
    _listenAuth();
  }
  final WatchAuthState _watchAuth;
  final WatchUser _watchUser;
  final WatchDriver _watchDriver;
  StreamSubscription<dynamic>? _driverSubscription;
  UserEntity? _profile;
  int _driverGeneration = 0;
  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<dynamic>? _profileSubscription;
  AuthUser? _authUser;
  int _generation = 0;

  void _listenAuth() {
    _authSubscription = _watchAuth(const NoParams()).listen(
      (result) {
        result.fold((failure) {
          _generation++;
          _cancelDriver();
          unawaited(_profileSubscription?.cancel());
          _authUser = null;
          emit(SessionError(failure));
        }, _onAuth);
      },
      onError: (Object error) {
        _generation++;
        _cancelDriver();
        unawaited(_profileSubscription?.cancel());
        _authUser = null;
        emit(const SessionError(UnexpectedFailure('auth-stream')));
      },
    );
  }

  void _onAuth(AuthUser? user) {
    _cancelDriver();
    _authUser = user;
    final generation = ++_generation;
    unawaited(_profileSubscription?.cancel());
    if (user == null) {
      emit(const SessionSignedOut());
      return;
    }
    if (kIsWeb) {
      emit(SessionWeb(user));
      return;
    }
    if (state is! SessionUnknown) emit(const SessionUnknown());
    _profileSubscription = _watchUser(user.uid).listen(
      (result) {
        if (isClosed || generation != _generation) return;
        result.fold(
          (failure) {
            _cancelDriver();
            emit(SessionError(failure));
          },
          (profile) {
            if (profile?.role != UserRole.driver) _cancelDriver();
            if (profile == null || profile.name.trim().isEmpty) {
              _cancelDriver();
              emit(SessionNeedsName(user));
            } else if (profile.role == null) {
              emit(SessionNeedsRole(profile));
            } else {
              if (profile.role == UserRole.driver) {
                _listenDriver(profile);
              } else {
                emit(SessionReady(profile));
              }
            }
          },
        );
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          _cancelDriver();
          emit(const SessionError(ServerFailure('profile-stream')));
        }
      },
    );
  }

  void _cancelDriver() {
    _driverGeneration++;
    unawaited(_driverSubscription?.cancel());
    _driverSubscription = null;
    _profile = null;
  }

  void _listenDriver(UserEntity profile) {
    _profile = profile;
    if (_driverSubscription != null) {
      final current = state;
      if (current is SessionReady) {
        emit(SessionReady(profile, driver: current.driver));
      }
      return;
    }
    final generation = ++_driverGeneration;
    _driverSubscription = _watchDriver(profile.id).listen(
      (result) {
        if (isClosed || generation != _driverGeneration) return;
        result.fold(
          (failure) => emit(SessionError(failure)),
          (driver) => emit(SessionReady(_profile!, driver: driver)),
        );
      },
      onError: (Object error) {
        if (!isClosed && generation == _driverGeneration) {
          emit(const SessionError(ServerFailure('driver-stream')));
        }
      },
    );
  }

  void retry() {
    if (_authUser != null) {
      _onAuth(_authUser);
      return;
    }
    emit(const SessionUnknown());
    unawaited(_authSubscription?.cancel());
    _listenAuth();
  }

  @override
  Future<void> close() async {
    _generation++;
    _driverGeneration++;
    await _driverSubscription?.cancel();
    await _authSubscription?.cancel();
    await _profileSubscription?.cancel();
    return super.close();
  }
}
