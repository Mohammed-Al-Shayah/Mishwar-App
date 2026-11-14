import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignOut implements UseCase<Unit, NoParams> {
  const SignOut(this._repository);
  final AuthRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.signOut();
}
