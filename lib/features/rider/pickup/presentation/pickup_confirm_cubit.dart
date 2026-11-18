import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/geo/trip_motion.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/pickup/domain/pickup_repository.dart';

enum PickupPhase { idle, moving, resolving, resolved, failure }

class PickupConfirmState extends Equatable {
  PickupConfirmState({
    required this.stop,
    this.phase = PickupPhase.idle,
    List<PickupSuggestion> suggestions = const [],
    this.farFromDevice = false,
  }) : suggestions = List.unmodifiable(suggestions);
  final RideStop stop;
  final PickupPhase phase;
  final List<PickupSuggestion> suggestions;
  final bool farFromDevice;
  bool get busy =>
      phase == PickupPhase.moving || phase == PickupPhase.resolving;
  @override
  List<Object> get props => [stop, phase, suggestions, farFromDevice];
}

@injectable
class PickupConfirmCubit extends Cubit<PickupConfirmState> {
  PickupConfirmCubit(
    this._reverse,
    this._suggestions,
    this._position,
    @factoryParam RideStop initial,
  ) : super(PickupConfirmState(stop: initial));
  final ReverseGeocode _reverse;
  final GetPickupSuggestions _suggestions;
  final CurrentPosition _position;
  GeoPointValue? _device;
  Timer? _timer;
  int _revision = 0;
  String _lang = 'ar';
  String _fallback = '';

  Future<void> start({required String lang, required String fallback}) async {
    _lang = lang;
    _fallback = fallback;
    final point = state.stop.location;
    cameraIdle();
    final result = await _position();
    if (isClosed) return;
    result.fold((_) {}, (p) {
      _device = p;
      _emit(state.stop, state.phase);
    });
    final suggestions = await _suggestions(point);
    if (isClosed) return;
    suggestions.fold(
      (_) {},
      (items) =>
          _emit(state.stop, state.phase, suggestions: List.unmodifiable(items)),
    );
  }

  void _emit(
    RideStop stop,
    PickupPhase phase, {
    List<PickupSuggestion>? suggestions,
  }) {
    emit(
      PickupConfirmState(
        stop: stop,
        phase: phase,
        suggestions: suggestions ?? state.suggestions,
        farFromDevice:
            _device != null && distanceMeters(_device!, stop.location) > 1000,
      ),
    );
  }

  void moving() {
    _timer?.cancel();
    ++_revision;
    _emit(state.stop, PickupPhase.moving);
  }

  void cameraMoved(GeoPointValue point) {
    _emit(
      RideStop(name: _fallback, address: '', location: point),
      PickupPhase.moving,
    );
  }

  void cameraIdle() {
    _timer?.cancel();
    final revision = ++_revision;
    _timer = Timer(const Duration(milliseconds: 400), () async {
      final point = state.stop.location;
      _emit(state.stop, PickupPhase.resolving);
      final result = await _reverse(point, _lang);
      if (isClosed || revision != _revision) return;
      result.fold(
        (_) => _emit(
          RideStop(name: _fallback, address: '', location: point),
          PickupPhase.failure,
        ),
        (stop) => _emit(stop, PickupPhase.resolved),
      );
    });
  }

  void select(PickupSuggestion suggestion) {
    moving();
    cameraMoved(suggestion.location);
    cameraIdle();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    ++_revision;
    return super.close();
  }
}
