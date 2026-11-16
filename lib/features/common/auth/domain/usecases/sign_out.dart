import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/unregister_push_token.dart';

@lazySingleton
class SignOut implements UseCase<Unit, NoParams> {
  const SignOut(this._repository, this._unregister);
  final UnregisterPushToken _unregister;
  final AuthRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    // Best effort: a push cleanup failure (e.g. offline) must never block
    // signing out; the server also drops stale tokens on send.
    await _unregister(params);
    return _repository.signOut();
  }
}
