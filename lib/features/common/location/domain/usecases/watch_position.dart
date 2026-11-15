import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@lazySingleton
class WatchPosition {
  const WatchPosition(this._repository);
  final LocationRepository _repository;
  Stream<Either<Failure, GeoPointValue>> call() => _repository.watchPosition();
}
