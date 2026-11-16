import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_token_sync.dart';

@lazySingleton
class RegisterPushToken implements UseCase<Unit, NoParams> {
  RegisterPushToken(this._push, this._sync, this._auth);
  final AuthRepository _auth;
  final PushRepository _push;
  final PushTokenSync _sync;
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    final uid = _auth.currentUser?.uid;
    final generation = _sync.generation;
    if (uid == null) return const Right(unit);
    final permission = await _push.requestPermission();
    final failure = permission.getLeft().toNullable();
    if (failure != null) return Left(failure);
    if (permission.getRight().toNullable() != true) return const Right(unit);
    final result = await _push.token();
    final tokenFailure = result.getLeft().toNullable();
    if (tokenFailure != null) return Left(tokenFailure);
    final token = result.getRight().toNullable();
    if (token == null) return const Right(unit);
    if (_auth.currentUser?.uid != uid || _sync.generation != generation) {
      return const Right(unit);
    }
    _sync.resume();
    return _sync.save(token);
  }
}
