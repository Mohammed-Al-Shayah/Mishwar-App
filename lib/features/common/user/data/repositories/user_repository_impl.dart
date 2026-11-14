import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/data/datasources/user_remote_data_source.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._source);
  final UserRemoteDataSource _source;
  Failure _failure(Object error) => switch (error) {
    FirebaseException(code: 'unavailable') => const NetworkFailure(
      'unavailable',
    ),
    FirebaseException(:final code) => ServerFailure(code),
    _ => const ServerFailure('profile-error'),
  };
  @override
  Stream<Either<Failure, UserEntity?>> watchUser(String uid) async* {
    try {
      await for (final model in _source.watchUser(uid)) {
        yield Right(model?.toEntity());
      }
    } on Object catch (error) {
      yield Left(_failure(error));
    }
  }

  Future<Either<Failure, Unit>> _write(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Right(unit);
    } on Object catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> createProfile({
    required String uid,
    required String phone,
    required String name,
  }) => _write(() => _source.createProfile(uid: uid, phone: phone, name: name));
  @override
  Future<Either<Failure, Unit>> setRole(String uid, UserRole role) =>
      _write(() => _source.setRole(uid, role));
}
