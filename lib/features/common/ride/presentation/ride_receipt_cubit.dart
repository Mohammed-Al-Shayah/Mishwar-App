import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';

class RideReceiptState extends Equatable {
  const RideReceiptState({this.ride, this.failure});
  final RideEntity? ride;
  final Failure? failure;
  @override
  List<Object?> get props => [ride, failure];
}

@injectable
class RideReceiptCubit extends Cubit<RideReceiptState> {
  RideReceiptCubit(this._watch) : super(const RideReceiptState());
  final WatchRide _watch;
  StreamSubscription<dynamic>? _subscription;
  Future<void> load(String id) async {
    await _subscription?.cancel();
    if (isClosed) return;
    emit(const RideReceiptState());
    _subscription = _watch(id).listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => emit(RideReceiptState(failure: failure)),
        (ride) => emit(RideReceiptState(ride: ride)),
      );
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
