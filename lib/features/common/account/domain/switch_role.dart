import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

@lazySingleton
class SwitchRole {
  const SwitchRole(this._repository);
  final AccountRepository _repository;
  Future<Either<Failure, Unit>> call(UserRole role) =>
      _repository.switchRole(role);
}
