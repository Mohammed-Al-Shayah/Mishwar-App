import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._firestore, this._functions);
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  Future<Either<Failure, Unit>> _write(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseFunctionsException catch (error) {
      final details = error.details;
      return Left(
        ServerFailure(
          error.code == 'failed-precondition' &&
                  details is Map &&
                  details['reason'] == 'busy'
              ? 'account-busy'
              : error.code,
        ),
      );
    } on Object {
      return const Left(ServerFailure('account-error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateName(String uid, String name) {
    final trimmed = name.trim();
    if (trimmed.runes.length < 2 || trimmed.runes.length > 40) {
      return Future.value(const Left(ValidationFailure('name')));
    }
    return _write(() => _firestore.doc('users/$uid').update({'name': trimmed}));
  }

  @override
  Future<Either<Failure, Unit>> switchRole(UserRole role) => _write(() async {
    await _functions.httpsCallable('switchRole').call<void>({
      'role': role.name,
    });
  });
  @override
  Future<Either<Failure, Unit>> deleteAccount() => _write(() async {
    await _functions.httpsCallable('deleteAccount').call<void>();
  });
}
