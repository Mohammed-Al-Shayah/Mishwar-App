import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

abstract class UserRepository {
  Stream<Either<Failure, UserEntity?>> watchUser(String uid);
  Future<Either<Failure, Unit>> createProfile({
    required String uid,
    required String phone,
    required String name,
  });
  Future<Either<Failure, Unit>> setRole(String uid, UserRole role);
}
