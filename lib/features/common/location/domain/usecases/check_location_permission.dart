import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';

@lazySingleton
class CheckLocationPermission {
  const CheckLocationPermission(this._repository);
  final LocationRepository _repository;
  Future<Either<Failure, LocationPermissionStatus>> call() =>
      _repository.checkPermission();
}
