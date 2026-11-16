import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

abstract class PlacesRepository {
  Future<Either<Failure, List<PlaceSuggestion>>> search({
    required String input,
    required String sessionToken,
    GeoPointValue? bias,
    String lang = 'ar',
  });
  Future<Either<Failure, PlaceDetails>> details({
    required String placeId,
    required String sessionToken,
    String lang = 'ar',
  });
}
