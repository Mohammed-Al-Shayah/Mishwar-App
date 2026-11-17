import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/data/admin_remote_data_source.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remote);
  final AdminRemoteDataSource _remote;
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on Object {
      return const Left(ServerFailure('admin-request'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signIn(String email, String password) =>
      _guard(() async {
        await _remote.signIn(email, password);
        return unit;
      });
  @override
  Future<Either<Failure, AdminData>> load(AdminQuery query) =>
      _guard(() => _remote.load(query));
  @override
  Future<Either<Failure, String>> license(String path) =>
      _guard(() => _remote.license(path));
  @override
  Future<Either<Failure, Unit>> action(
    String name,
    Map<String, Object> arguments,
  ) => _guard(() async {
    await _remote.action(name, arguments);
    return unit;
  });
  @override
  Stream<Either<Failure, AdminData>> watch(AdminSection section) async* {
    try {
      await for (final data in _remote.watch(section)) {
        yield Right(data);
      }
    } on Object {
      yield const Left(ServerFailure('admin-stream'));
    }
  }
}
