import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';

@lazySingleton
class UpdateDriverLocation {
  const UpdateDriverLocation(this._repository);
  final DriverPresenceRepository _repository;
  Future<Either<Failure, Unit>> call(GeoPointValue point, {double? heading}) =>
      _repository.updateLocation(point, heading: heading);
}
