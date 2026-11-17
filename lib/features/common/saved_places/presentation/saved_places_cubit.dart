import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_places_usecases.dart';

class SavedPlacesState extends Equatable {
  const SavedPlacesState({
    this.places = const [],
    this.loading = true,
    this.saving = false,
    this.failure,
  });
  final List<SavedPlace> places;
  final bool loading;
  final bool saving;
  final Failure? failure;
  @override
  List<Object?> get props => [places, loading, saving, failure];
}

@injectable
class SavedPlacesCubit extends Cubit<SavedPlacesState> {
  SavedPlacesCubit(
    this._watch,
    this._upsert,
    this._add,
    this._rename,
    this._delete,
  ) : super(const SavedPlacesState());
  final WatchSavedPlaces _watch;
  final UpsertSavedPlace _upsert;
  final AddOtherSavedPlace _add;
  final RenameSavedPlace _rename;
  final DeleteSavedPlace _delete;
  StreamSubscription<Either<Failure, List<SavedPlace>>>? _subscription;
  String? _uid;
  int _generation = 0;
  Future<void> start(String uid) async {
    final generation = ++_generation;
    _uid = uid;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(const SavedPlacesState());
    _subscription = _watch(uid).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) => emit(
          SavedPlacesState(
            places: state.places,
            loading: false,
            saving: state.saving,
            failure: failure,
          ),
        ),
        (places) => emit(
          SavedPlacesState(
            places: places,
            loading: false,
            saving: state.saving,
          ),
        ),
      );
    });
  }

  Future<bool> save(SavedPlace place) => _mutate(() {
    if (place.label == SavedPlaceLabel.other && place.id.isEmpty) {
      if (state.places.where((p) => p.label == SavedPlaceLabel.other).length >=
          20) {
        return Future.value(
          const Left(ValidationFailure('saved-places-limit')),
        );
      }
      return _add(_uid!, place);
    }
    return _upsert(_uid!, place);
  });
  Future<bool> rename(String id, String name) =>
      _mutate(() => _rename(_uid!, id, name));
  Future<bool> delete(String id) => _mutate(() => _delete(_uid!, id));
  Future<bool> _mutate(Future<Either<Failure, Unit>> Function() action) async {
    if (_uid == null || state.loading || state.saving || isClosed) return false;
    final generation = _generation;
    emit(SavedPlacesState(places: state.places, loading: false, saving: true));
    final result = await action();
    if (isClosed || generation != _generation) return false;
    final failure = result.getLeft().toNullable();
    emit(
      SavedPlacesState(places: state.places, loading: false, failure: failure),
    );
    return failure == null;
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
