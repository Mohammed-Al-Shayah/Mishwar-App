import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';

@lazySingleton
class WatchUser {
  const WatchUser(this._repository);
  final UserRepository _repository;
  Stream<Either<Failure, UserEntity?>> call(String uid) =>
      _repository.watchUser(uid);
}
