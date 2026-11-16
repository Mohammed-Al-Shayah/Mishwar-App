import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_token_sync.dart';

@lazySingleton
class UnregisterPushToken implements UseCase<Unit, NoParams> {
  UnregisterPushToken(this._push, this._auth, this._sync);
  final PushRepository _push;
  final AuthRepository _auth;
  final PushTokenSync _sync;
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    await _sync.suspend();
    final uid = _auth.currentUser?.uid;
    final removed = uid == null
        ? const Right<Failure, Unit>(unit)
        : await _push.removeToken(uid);
    final deleted = await _push.deleteToken();
    return removed.isLeft() ? removed : deleted;
  }
}
