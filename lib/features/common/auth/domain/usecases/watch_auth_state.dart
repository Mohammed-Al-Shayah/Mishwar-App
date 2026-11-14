import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class WatchAuthState implements StreamUseCase<AuthUser?, NoParams> {
  const WatchAuthState(this._repository);
  final AuthRepository _repository;
  @override
  Stream<Either<Failure, AuthUser?>> call(NoParams params) async* {
    try {
      await for (final user in _repository.authStateChanges()) {
        yield Right(user);
      }
    } on Exception catch (error) {
      yield Left(UnexpectedFailure(error.toString()));
    }
  }
}
