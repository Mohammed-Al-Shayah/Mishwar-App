import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';

@lazySingleton
class RequestLocationPermission {
  const RequestLocationPermission(this._repository);
  final LocationRepository _repository;
  Future<Either<Failure, LocationPermissionStatus>> call() =>
      _repository.requestPermission();
}
