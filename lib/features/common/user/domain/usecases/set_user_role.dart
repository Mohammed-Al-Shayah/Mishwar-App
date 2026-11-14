import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';

@lazySingleton
class SetUserRole {
  const SetUserRole(this._repository);
  final UserRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, UserRole role) =>
      _repository.setRole(uid, role);
}
