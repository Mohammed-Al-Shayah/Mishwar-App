import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

class AppConfigState extends Equatable {
  AppConfigState({
    List<AppBanner> banners = const [],
    List<AppService> services = AppService.defaults,
    this.failure,
  }) : banners = List.unmodifiable(banners),
       services = List.unmodifiable(services);
  final List<AppBanner> banners;
  final List<AppService> services;
  final Failure? failure;
  @override
  List<Object?> get props => [banners, services, failure];
}

@lazySingleton
class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit(this._watchBanners, this._watchServices)
    : super(AppConfigState());
  final WatchBanners _watchBanners;
  final WatchServices _watchServices;
  StreamSubscription<dynamic>? _banners;
  StreamSubscription<dynamic>? _services;
  String? _uid;
  int _generation = 0;
  Future<void> start(String uid) async {
    if (_uid == uid || isClosed) return;
    final generation = ++_generation;
    _uid = uid;
    await _cancelSubscriptions();
    if (isClosed || generation != _generation) return;
    emit(AppConfigState());
    _banners = _watchBanners().listen(
      (result) {
        if (isClosed || generation != _generation) return;
        result.fold(
          (f) => emit(AppConfigState(services: state.services, failure: f)),
          (b) => emit(AppConfigState(banners: b, services: state.services)),
        );
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          emit(
            AppConfigState(
              services: state.services,
              failure: const ServerFailure('banners'),
            ),
          );
        }
      },
    );
    _services = _watchServices().listen(
      (result) {
        if (isClosed || generation != _generation) return;
        result.fold(
          (f) => emit(AppConfigState(banners: state.banners, failure: f)),
          (s) => emit(AppConfigState(banners: state.banners, services: s)),
        );
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          emit(
            AppConfigState(
              banners: state.banners,
              failure: const ServerFailure('services'),
            ),
          );
        }
      },
    );
  }

  Future<void> stop() async {
    ++_generation;
    _uid = null;
    if (!isClosed) emit(AppConfigState());
    await _cancelSubscriptions();
  }

  Future<void> _cancelSubscriptions() async {
    final pending = Future.wait<void>([
      if (_banners != null) _banners!.cancel(),
      if (_services != null) _services!.cancel(),
    ]);
    _banners = null;
    _services = null;
    await pending;
  }

  @override
  Future<void> close() async {
    ++_generation;
    _uid = null;
    await _cancelSubscriptions();
    return super.close();
  }
}
