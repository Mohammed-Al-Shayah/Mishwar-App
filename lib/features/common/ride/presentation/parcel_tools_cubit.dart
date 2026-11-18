import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/usecases/parcel_usecases.dart';

class ParcelToolsState extends Equatable {
  const ParcelToolsState({
    this.code,
    this.url,
    this.busy = false,
    this.failure,
  });
  final String? code;
  final Uri? url;
  final bool busy;
  final Failure? failure;
  @override
  List<Object?> get props => [code, url, busy, failure];
}

@injectable
class ParcelToolsCubit extends Cubit<ParcelToolsState> {
  ParcelToolsCubit(this._watch, this._photo) : super(const ParcelToolsState());
  final WatchDeliveryCode _watch;
  final GetParcelPhotoUrl _photo;
  StreamSubscription<dynamic>? _subscription;
  void watch(String id) {
    unawaited(_subscription?.cancel());
    _subscription = _watch(id).listen((r) {
      if (isClosed) return;
      r.fold(
        (f) => emit(ParcelToolsState(failure: f)),
        (code) => emit(ParcelToolsState(code: code)),
      );
    });
  }

  Future<void> photo(String id) async {
    if (state.busy) return;
    emit(const ParcelToolsState(busy: true));
    final result = await _photo(id);
    if (isClosed) return;
    result.fold(
      (f) => emit(ParcelToolsState(failure: f)),
      (url) => emit(ParcelToolsState(url: url)),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
