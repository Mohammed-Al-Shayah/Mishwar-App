import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

abstract class AccountRepository {
  Future<Either<Failure, Unit>> updateName(String uid, String name);
  Future<Either<Failure, Unit>> switchRole(UserRole role);
  Future<Either<Failure, Unit>> deleteAccount();
}
