import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';

@lazySingleton
class DeleteAccount {
  const DeleteAccount(this._repository);
  final AccountRepository _repository;
  Future<Either<Failure, Unit>> call() => _repository.deleteAccount();
}
