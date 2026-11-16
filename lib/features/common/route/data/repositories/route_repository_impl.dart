import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/route/data/datasources/route_remote_data_source.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/repositories/route_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@LazySingleton(as: RouteRepository)
class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl(this._source);
  final RouteRemoteDataSource _source;
  @override
  Future<Either<Failure, FareEstimates>> getFareEstimates({
    required GeoPointValue origin,
    required GeoPointValue destination,
  }) async {
    try {
      return Right(
        (await _source.estimates({
          'origin': {'lat': origin.lat, 'lng': origin.lng},
          'destination': {'lat': destination.lat, 'lng': destination.lng},
        })).toEntity(),
      );
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
