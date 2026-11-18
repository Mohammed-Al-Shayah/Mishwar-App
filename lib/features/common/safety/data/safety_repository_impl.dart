import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/safety/data/safety_remote_data_source.dart';
import 'package:mishwar/features/common/safety/domain/safety_repository.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';

@LazySingleton(as: SafetyRepository)
class SafetyRepositoryImpl implements SafetyRepository {
  SafetyRepositoryImpl(this._source);
  final SafetyRemoteDataSource _source;
  @override
  Stream<Either<Failure, List<TrustedContact>>> watch(String uid) async* {
    try {
      await for (final models in _source.watch(uid)) {
        yield Right(List.unmodifiable(models.map((model) => model.toEntity())));
      }
    } on Exception {
      yield const Left(ServerFailure('safety'));
    }
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ContactsLimitException {
      return const Left(ValidationFailure('trusted-contacts-limit'));
    } on Exception {
      return const Left(ServerFailure('safety'));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(String uid, TrustedContact contact) =>
      _guard(() async {
        await _source.save(uid, contact);
        return unit;
      });
  @override
  Future<Either<Failure, Unit>> delete(String uid, String id) =>
      _guard(() async {
        await _source.delete(uid, id);
        return unit;
      });
  @override
  Future<Either<Failure, String>> createShareLink(String rideId) =>
      _guard(() => _source.createShareLink(rideId));
}
