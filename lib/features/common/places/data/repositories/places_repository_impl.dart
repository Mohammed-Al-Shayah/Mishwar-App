import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/places/data/datasources/places_remote_data_source.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';
import 'package:mishwar/features/common/places/domain/repositories/places_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@LazySingleton(as: PlacesRepository)
class PlacesRepositoryImpl implements PlacesRepository {
  const PlacesRepositoryImpl(this._source);
  final PlacesRemoteDataSource _source;
  @override
  Future<Either<Failure, List<PlaceSuggestion>>> search({
    required String input,
    required String sessionToken,
    GeoPointValue? bias,
    String lang = 'ar',
  }) async {
    try {
      final models = await _source.search({
        'input': input,
        'sessionToken': sessionToken,
        'lang': lang,
        if (bias != null) ...{'lat': bias.lat, 'lng': bias.lng},
      });
      return Right(List.unmodifiable(models.map((model) => model.toEntity())));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }

  @override
  Future<Either<Failure, PlaceDetails>> details({
    required String placeId,
    required String sessionToken,
    String lang = 'ar',
  }) async {
    try {
      return Right(
        (await _source.details({
          'placeId': placeId,
          'sessionToken': sessionToken,
          'lang': lang,
        })).toEntity(),
      );
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
