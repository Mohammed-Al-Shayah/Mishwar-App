import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';

abstract class SavedPlacesRepository {
  Stream<Either<Failure, List<SavedPlace>>> watch(String uid);
  Future<Either<Failure, Unit>> upsert(String uid, SavedPlace place);
  Future<Either<Failure, Unit>> addOther(String uid, SavedPlace place);
  Future<Either<Failure, Unit>> rename(String uid, String id, String name);
  Future<Either<Failure, Unit>> delete(String uid, String id);
}

bool validSavedPlace(SavedPlace place) =>
    place.name.trim().isNotEmpty &&
    place.name.trim().runes.length <= 40 &&
    place.address.runes.length <= 200 &&
    place.location.lat.isFinite &&
    place.location.lng.isFinite &&
    place.location.lat.abs() <= 90 &&
    place.location.lng.abs() <= 180;
