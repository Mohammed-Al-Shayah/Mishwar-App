import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_places_repository.dart';

@lazySingleton
class WatchSavedPlaces {
  const WatchSavedPlaces(this._repository);
  final SavedPlacesRepository _repository;
  Stream<Either<Failure, List<SavedPlace>>> call(String uid) =>
      _repository.watch(uid);
}

@lazySingleton
class UpsertSavedPlace {
  const UpsertSavedPlace(this._repository);
  final SavedPlacesRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, SavedPlace place) {
    if (!validSavedPlace(place) ||
        (place.label == SavedPlaceLabel.other && place.id.isEmpty)) {
      return Future.value(const Left(ValidationFailure('saved-place')));
    }
    return _repository.upsert(uid, place);
  }
}

@lazySingleton
class AddOtherSavedPlace {
  const AddOtherSavedPlace(this._repository);
  final SavedPlacesRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, SavedPlace place) {
    if (!validSavedPlace(place) || place.label != SavedPlaceLabel.other) {
      return Future.value(const Left(ValidationFailure('saved-place')));
    }
    return _repository.addOther(uid, place);
  }
}

@lazySingleton
class RenameSavedPlace {
  const RenameSavedPlace(this._repository);
  final SavedPlacesRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, String id, String name) {
    if (name.trim().isEmpty || name.trim().runes.length > 40) {
      return Future.value(const Left(ValidationFailure('saved-place')));
    }
    return _repository.rename(uid, id, name.trim());
  }
}

@lazySingleton
class DeleteSavedPlace {
  const DeleteSavedPlace(this._repository);
  final SavedPlacesRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, String id) =>
      _repository.delete(uid, id);
}
