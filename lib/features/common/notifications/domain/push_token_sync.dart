import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';

@lazySingleton
class PushTokenSync {
  PushTokenSync(this._push, this._auth);
  final PushRepository _push;
  final AuthRepository _auth;
  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<dynamic>? _refreshSubscription;
  Future<void> _pending = Future.value();
  String? _uid;
  int _generation = 0;
  bool _suspended = false;
  int get generation => _generation;

  void start() {
    if (_authSubscription != null) return;
    _uid = _auth.currentUser?.uid;
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (_uid == user?.uid) return;
      _uid = user?.uid;
      _generation++;
      _suspended = false;
    }, onError: (Object _) {});
    _refreshSubscription = _push.onTokenRefresh.listen((result) {
      result.fold((_) {}, (token) {
        unawaited(save(token));
      });
    }, onError: (Object _) {});
  }

  Future<Either<Failure, Unit>> save(String token) {
    final uid = _auth.currentUser?.uid;
    final generation = _generation;
    final result = _pending.then((_) async {
      if (_suspended ||
          uid == null ||
          _auth.currentUser?.uid != uid ||
          generation != _generation) {
        return const Right<Failure, Unit>(unit);
      }
      return _push.saveToken(uid, token);
    });
    _pending = result.then((_) {});
    return result;
  }

  void resume() {
    _suspended = false;
  }

  Future<void> suspend() async {
    _suspended = true;
    _generation++;
    await _pending;
  }

  @disposeMethod
  Future<void> dispose() async {
    await suspend();
    await _authSubscription?.cancel();
    await _refreshSubscription?.cancel();
    _authSubscription = null;
    _refreshSubscription = null;
  }
}
