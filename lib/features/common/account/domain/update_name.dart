import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';

@lazySingleton
class UpdateName {
  const UpdateName(this._repository);
  final AccountRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, String name) {
    final trimmed = name.trim();
    if (trimmed.runes.length < 2 || trimmed.runes.length > 40) {
      return Future.value(const Left(ValidationFailure('name')));
    }
    return _repository.updateName(uid, trimmed);
  }
}
