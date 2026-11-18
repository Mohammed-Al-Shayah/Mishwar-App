import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/promos/data/promo_remote_data_source.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/promos/domain/promo_repository.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

@LazySingleton(as: PromoRepository)
class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl(this._source);
  final PromoRemoteDataSource _source;
  @override
  Future<Either<Failure, PromoQuote>> validate(
    String code,
    RideDraft draft,
    VehicleType vehicleType,
  ) async {
    try {
      final data = await _source.validate({
        'code': code,
        'vehicleType': vehicleType.name,
        'pickup': {
          'lat': draft.pickup.location.lat,
          'lng': draft.pickup.location.lng,
        },
        'dropoff': {
          'lat': draft.dropoff.location.lat,
          'lng': draft.dropoff.location.lng,
        },
      });
      return Right(data.toEntity());
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
