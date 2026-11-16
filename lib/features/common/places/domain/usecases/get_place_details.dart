import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';

import 'package:mishwar/features/common/places/domain/repositories/places_repository.dart';

@lazySingleton
class GetPlaceDetails {
  const GetPlaceDetails(this._repository);
  final PlacesRepository _repository;
  Future<Either<Failure, PlaceDetails>> call({
    required String placeId,
    required String sessionToken,
    String lang = 'ar',
  }) => _repository.details(
    placeId: placeId,
    sessionToken: sessionToken,
    lang: lang,
  );
}
