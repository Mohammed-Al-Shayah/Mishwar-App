import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';

@lazySingleton
class WatchDriver {
  const WatchDriver(this._repository);
  final DriverRepository _repository;
  Stream<Either<Failure, DriverEntity?>> call(String uid) =>
      _repository.watchDriver(uid);
}
