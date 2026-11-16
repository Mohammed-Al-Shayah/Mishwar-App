import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

// A repository boundary is intentionally an injectable interface.
// ignore: one_member_abstracts
abstract class RouteRepository {
  Future<Either<Failure, FareEstimates>> getFareEstimates({
    required GeoPointValue origin,
    required GeoPointValue destination,
  });
}
