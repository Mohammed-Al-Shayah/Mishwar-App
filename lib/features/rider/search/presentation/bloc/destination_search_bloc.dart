import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/places/domain/places_session_token.dart';
import 'package:mishwar/features/common/places/domain/usecases/get_place_details.dart';
import 'package:mishwar/features/common/places/domain/usecases/search_places.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_event.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_state.dart';

/// A typed route argument permits an absent location bias, but rejects links
/// without a search session.
class DestinationSearchParams {
  const DestinationSearchParams({this.position, this.language = 'ar'});
  final GeoPointValue? position;
  final String language;
}

@injectable
class DestinationSearchBloc
    extends Bloc<DestinationSearchEvent, DestinationSearchState> {
  DestinationSearchBloc(this._search, this._details, @factoryParam this.params)
    : super(const DestinationIdle()) {
    on<DestinationSearchEvent>(_handle, transformer: _debounceQueries());
  }

  // Cancelling the mapped subscription cancels Bloc's emitter immediately.
  // The latest event starts its own debounce without waiting for cancellation.
  static EventTransformer<DestinationSearchEvent> _debounceQueries() =>
      (events, mapper) {
        Timer? timer;
        StreamSubscription<DestinationSearchEvent>? active;
        late final StreamSubscription<DestinationSearchEvent> source;
        late final StreamController<DestinationSearchEvent> controller;
        var sourceDone = false;
        controller = StreamController<DestinationSearchEvent>(
          onListen: () {
            source = events.listen(
              (event) {
                timer?.cancel();
                timer = null;
                unawaited(active?.cancel());
                active = null;
                void start() {
                  timer = null;
                  active = mapper(event).listen(
                    controller.add,
                    onError: controller.addError,
                    onDone: () {
                      active = null;
                      if (sourceDone) unawaited(controller.close());
                    },
                  );
                }

                if (event is QueryChanged && event.text.trim().length >= 2) {
                  timer = Timer(const Duration(milliseconds: 300), start);
                } else {
                  start();
                }
              },
              onError: controller.addError,
              onDone: () {
                sourceDone = true;
                if (timer == null && active == null) {
                  unawaited(controller.close());
                }
              },
            );
          },
          onCancel: () async {
            timer?.cancel();
            await source.cancel();
            await active?.cancel();
          },
        );
        return controller.stream;
      };
  final SearchPlaces _search;
  final GetPlaceDetails _details;
  final DestinationSearchParams params;
  final PlacesSessionToken _token = PlacesSessionToken();
  String _query = '';
  SuggestionSelected? _failedSelection;

  Future<void> _handle(
    DestinationSearchEvent event,
    Emitter<DestinationSearchState> emit,
  ) async {
    if (event is Cleared) {
      _query = '';
      _failedSelection = null;
      emit(const DestinationIdle());
      return;
    }
    if (event is QueryChanged) {
      _query = event.text.trim();
      _failedSelection = null;
    }
    final selection = event is SuggestionSelected
        ? event
        : event is Retry
        ? _failedSelection
        : null;
    if (selection != null) {
      final token = _token.value;
      _token.renew();
      emit(DestinationResolving(selection.suggestion, state.suggestions));
      final result = await _details(
        placeId: selection.suggestion.placeId,
        sessionToken: token,
        lang: params.language,
      );
      // Ignore details cancelled by a later query or clear.
      if (emit.isDone) return;
      result.fold(
        (failure) {
          _failedSelection = selection;
          emit(DestinationFailure(failure, _query));
        },
        (details) {
          _failedSelection = null;
          emit(DestinationChosen(details));
        },
      );
      return;
    }
    if (_query.length < 2) {
      emit(const DestinationIdle());
      return;
    }
    emit(DestinationLoading(state.suggestions));
    final result = await _search(
      input: _query,
      sessionToken: _token.value,
      bias: params.position,
      lang: params.language,
    );
    if (emit.isDone) return;
    result.fold(
      (failure) => emit(DestinationFailure(failure, _query)),
      (results) => emit(
        results.isEmpty
            ? DestinationEmpty(_query)
            : DestinationResults(results),
      ),
    );
  }
}
