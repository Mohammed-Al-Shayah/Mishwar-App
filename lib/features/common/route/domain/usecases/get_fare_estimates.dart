import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/repositories/route_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@lazySingleton
class GetFareEstimates {
  const GetFareEstimates(this._repository);
  final RouteRepository _repository;
  Future<Either<Failure, FareEstimates>> call({
    required GeoPointValue origin,
    required GeoPointValue destination,
  }) => _repository.getFareEstimates(origin: origin, destination: destination);
}
