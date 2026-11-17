import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';

@lazySingleton
class AdminSignIn {
  const AdminSignIn(this._repository);
  final AdminRepository _repository;
  Future<Either<Failure, Unit>> call(String email, String password) =>
      _repository.signIn(email, password);
}

@lazySingleton
class WatchAdminData {
  const WatchAdminData(this._repository);
  final AdminRepository _repository;
  Stream<Either<Failure, AdminData>> call(AdminSection section) =>
      _repository.watch(section);
}

@lazySingleton
class LoadAdminPage {
  const LoadAdminPage(this._repository);
  final AdminRepository _repository;
  Future<Either<Failure, AdminData>> call(AdminQuery query) =>
      _repository.load(query);
}

@lazySingleton
class LoadAdminLicense {
  const LoadAdminLicense(this._repository);
  final AdminRepository _repository;
  Future<Either<Failure, String>> call(String path) =>
      _repository.license(path);
}

@lazySingleton
class AdminAction {
  const AdminAction(this._repository);
  final AdminRepository _repository;
  Future<Either<Failure, Unit>> call(
    String name,
    Map<String, Object> arguments,
  ) => _repository.action(name, arguments);
}
