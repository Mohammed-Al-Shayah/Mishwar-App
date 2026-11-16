import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';

import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';

@lazySingleton
class GoOffline {
  const GoOffline(this._repository);
  final DriverPresenceRepository _repository;
  Future<Either<Failure, Unit>> call() => _repository.goOffline();
}
