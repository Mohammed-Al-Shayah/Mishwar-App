import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';

@lazySingleton
class CreateUserProfile {
  const CreateUserProfile(this._repository);
  final UserRepository _repository;
  Future<Either<Failure, Unit>> call({
    required String uid,
    required String phone,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.runes.length < 2 || trimmed.runes.length > 40) {
      return const Left(ValidationFailure('name-length'));
    }
    return _repository.createProfile(uid: uid, phone: phone, name: trimmed);
  }
}
