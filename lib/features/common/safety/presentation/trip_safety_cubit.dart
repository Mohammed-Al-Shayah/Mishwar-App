import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/safety/domain/safety_usecases.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class TripSafetyState extends Equatable {
  const TripSafetyState({this.busy = false, this.failure, this.url});
  final bool busy;
  final Failure? failure;
  final String? url;
  @override
  List<Object?> get props => [busy, failure, url];
}

@injectable
class TripSafetyCubit extends Cubit<TripSafetyState> {
  TripSafetyCubit(this._share, this._position) : super(const TripSafetyState());
  final CreateShareLink _share;
  final CurrentPosition _position;
  Future<String?> shareLink(String rideId) async {
    if (state.busy) return null;
    emit(TripSafetyState(busy: true, url: state.url));
    final result = await _share(rideId);
    if (isClosed) return null;
    final url = result.getRight().toNullable();
    emit(TripSafetyState(url: url, failure: result.getLeft().toNullable()));
    return url;
  }

  Future<GeoPointValue?> position() async {
    if (state.busy) return null;
    emit(TripSafetyState(busy: true, url: state.url));
    final result = await _position();
    if (isClosed) return null;
    emit(
      TripSafetyState(url: state.url, failure: result.getLeft().toNullable()),
    );
    return result.getRight().toNullable();
  }
}
