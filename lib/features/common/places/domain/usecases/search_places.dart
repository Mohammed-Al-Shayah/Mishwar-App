import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';
import 'package:mishwar/features/common/places/domain/repositories/places_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@lazySingleton
class SearchPlaces {
  const SearchPlaces(this._repository);
  final PlacesRepository _repository;
  Future<Either<Failure, List<PlaceSuggestion>>> call({
    required String input,
    required String sessionToken,
    GeoPointValue? bias,
    String lang = 'ar',
  }) => _repository.search(
    input: input,
    sessionToken: sessionToken,
    bias: bias,
    lang: lang,
  );
}
