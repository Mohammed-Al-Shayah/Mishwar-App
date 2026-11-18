import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/pickup/data/pickup_models.dart';
import 'package:mishwar/features/rider/pickup/domain/pickup_repository.dart';

@lazySingleton
class PickupRemoteDataSource {
  const PickupRemoteDataSource(this._functions);
  final FirebaseFunctions _functions;
  Future<PickupAddressModel> reverse(GeoPointValue point, String lang) async {
    final result = await _functions
        .httpsCallable('reverseGeocode')
        .call<Map<String, dynamic>>({
          'lat': point.lat,
          'lng': point.lng,
          'lang': lang,
        });
    return PickupAddressModel.fromJson(result.data);
  }

  Future<List<PickupSuggestionModel>> suggestions(GeoPointValue point) async {
    final result = await _functions
        .httpsCallable('pickupSuggestions')
        .call<List<dynamic>>({'lat': point.lat, 'lng': point.lng});
    return List.unmodifiable(
      result.data.map((value) {
        final p = Map<String, dynamic>.from(value as Map);
        return PickupSuggestionModel.fromJson(p);
      }),
    );
  }
}

@LazySingleton(as: PickupRepository)
class PickupRepositoryImpl implements PickupRepository {
  const PickupRepositoryImpl(this._source);
  final PickupRemoteDataSource _source;
  @override
  Future<Either<Failure, RideStop>> reverse(
    GeoPointValue point,
    String lang,
  ) async {
    try {
      return Right((await _source.reverse(point, lang)).toEntity(point));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<PickupSuggestion>>> suggestions(
    GeoPointValue point,
  ) async {
    try {
      return Right(
        List.unmodifiable(
          (await _source.suggestions(point)).map((model) => model.toEntity()),
        ),
      );
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
