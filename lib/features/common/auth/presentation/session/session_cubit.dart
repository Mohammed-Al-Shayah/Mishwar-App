import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';

@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._watchAuth, this._watchUser)
    : super(const SessionUnknown()) {
    _listenAuth();
  }
  final WatchAuthState _watchAuth;
  final WatchUser _watchUser;
  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<dynamic>? _profileSubscription;
  AuthUser? _authUser;
  int _generation = 0;

  void _listenAuth() {
    _authSubscription = _watchAuth(const NoParams()).listen(
      (result) {
        result.fold((failure) {
          _generation++;
          unawaited(_profileSubscription?.cancel());
          _authUser = null;
          emit(SessionError(failure));
        }, _onAuth);
      },
      onError: (Object error) =>
          emit(const SessionError(UnexpectedFailure('auth-stream'))),
    );
  }

  void _onAuth(AuthUser? user) {
    _authUser = user;
    final generation = ++_generation;
    unawaited(_profileSubscription?.cancel());
    if (user == null) {
      emit(const SessionSignedOut());
      return;
    }
    if (state is! SessionUnknown) emit(const SessionUnknown());
    _profileSubscription = _watchUser(user.uid).listen(
      (result) {
        if (isClosed || generation != _generation) return;
        result.fold((failure) => emit(SessionError(failure)), (profile) {
          if (profile == null || profile.name.trim().isEmpty) {
            emit(SessionNeedsName(user));
          } else if (profile.role == null) {
            emit(SessionNeedsRole(profile));
          } else {
            emit(SessionReady(profile));
          }
        });
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          emit(const SessionError(ServerFailure('profile-stream')));
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
    await _authSubscription?.cancel();
    await _profileSubscription?.cancel();
    return super.close();
  }
}
