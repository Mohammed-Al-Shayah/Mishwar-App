import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/domain/airport_config.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class AirportState extends Equatable {
  const AirportState({this.config, this.loading = false, this.failure});
  final AirportConfig? config;
  final bool loading;
  final Failure? failure;
  @override
  List<Object?> get props => [config, loading, failure];
}

@injectable
class AirportCubit extends Cubit<AirportState> {
  AirportCubit(this._config, this._position)
    : super(const AirportState(loading: true));
  final GetAirportConfig _config;
  final CurrentPosition _position;
  Future<void> load() async {
    emit(const AirportState(loading: true));
    final result = await _config();
    if (isClosed) return;
    result.fold(
      (f) => emit(AirportState(failure: f)),
      (c) => emit(AirportState(config: c)),
    );
  }

  Future<GeoPointValue?> pickup() async {
    final config = state.config;
    emit(AirportState(config: config, loading: true));
    final result = await _position();
    if (isClosed) return null;
    return result.fold(
      (f) {
        emit(AirportState(config: config, failure: f));
        return null;
      },
      (p) {
        emit(AirportState(config: config));
        return p;
      },
    );
  }
}
