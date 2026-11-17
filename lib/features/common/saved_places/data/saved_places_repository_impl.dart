import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/saved_places/data/saved_places_remote_data_source.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_places_repository.dart';

@LazySingleton(as: SavedPlacesRepository)
class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  SavedPlacesRepositoryImpl(this._source);
  final SavedPlacesRemoteDataSource _source;
  @override
  Stream<Either<Failure, List<SavedPlace>>> watch(String uid) async* {
    try {
      await for (final models in _source.watch(uid)) {
        final places = models.map((model) => model.toEntity()).toList()
          ..sort((a, b) {
            final label = a.label.index.compareTo(b.label.index);
            return label != 0 ? label : a.name.compareTo(b.name);
          });
        yield Right(List.unmodifiable(places));
      }
    } on Exception {
      yield const Left(ServerFailure('saved-places'));
    }
  }

  Future<Either<Failure, Unit>> _write(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on SavedPlacesLimitException {
      return const Left(ValidationFailure('saved-places-limit'));
    } on Exception {
      return const Left(ServerFailure('saved-places'));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsert(String uid, SavedPlace place) =>
      _write(() => _source.upsert(uid, place));
  @override
  Future<Either<Failure, Unit>> addOther(String uid, SavedPlace place) =>
      _write(() => _source.addOther(uid, place));
  @override
  Future<Either<Failure, Unit>> rename(String uid, String id, String name) =>
      _write(() => _source.rename(uid, id, name));
  @override
  Future<Either<Failure, Unit>> delete(String uid, String id) =>
      _write(() => _source.delete(uid, id));
}
