import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

class AdminContentState extends Equatable {
  AdminContentState({
    List<AppBanner> banners = const [],
    List<AppService> services = AppService.defaults,
    this.busy = false,
    this.dirty = false,
    this.failure,
    this.loading = true,
  }) : banners = List.unmodifiable(banners),
       services = List.unmodifiable(services);
  final List<AppBanner> banners;
  final List<AppService> services;
  final bool busy;
  final bool dirty;
  final bool loading;
  final Failure? failure;
  @override
  List<Object?> get props => [banners, services, busy, dirty, failure, loading];
}

@injectable
class AdminContentCubit extends Cubit<AdminContentState> {
  AdminContentCubit(this._watch, this._watchServices, this._action)
    : super(AdminContentState());
  final WatchAllBanners _watch;
  final WatchServices _watchServices;
  final AdminAction _action;
  StreamSubscription<dynamic>? _subscription;
  StreamSubscription<dynamic>? _services;
  void start() {
    if (_subscription != null) return;
    _subscription = _watch().listen(
      (result) => result.fold(
        (f) => _set(failure: f, loading: false),
        (b) => _set(banners: b, loading: false),
      ),
      onError: (Object error) =>
          _set(failure: const ServerFailure('content'), loading: false),
    );
    _services = _watchServices().listen(
      (result) => result.fold((f) => _set(failure: f), (services) {
        if (!state.dirty) _set(services: services);
      }),
      onError: (Object error) => _set(failure: const ServerFailure('services')),
    );
  }

  void _set({
    List<AppBanner>? banners,
    List<AppService>? services,
    bool? busy,
    bool? dirty,
    bool? loading,
    Failure? failure,
  }) {
    if (isClosed) return;
    emit(
      AdminContentState(
        banners: banners ?? state.banners,
        services: services ?? state.services,
        busy: busy ?? state.busy,
        dirty: dirty ?? state.dirty,
        loading: loading ?? state.loading,
        failure: failure,
      ),
    );
  }

  void toggle(ServiceId id, {required bool enabled}) {
    if (state.busy) return;
    _set(
      services: [
        for (final service in state.services)
          if (service.id == id)
            AppService(id: id, enabled: enabled, order: service.order)
          else
            service,
      ],
      dirty: true,
    );
  }

  void move(ServiceId id, int offset) {
    if (state.busy) return;
    final services = List<AppService>.of(state.services);
    final index = services.indexWhere((s) => s.id == id);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= services.length) return;
    final item = services.removeAt(index);
    services.insert(target, item);
    _set(
      services: [
        for (var i = 0; i < services.length; i++)
          AppService(
            id: services[i].id,
            enabled: services[i].enabled,
            order: i,
          ),
      ],
      dirty: true,
    );
  }

  Future<bool> saveServices() async {
    final saved = await save('updateServices', {
      'services': [
        for (final s in state.services)
          {'id': s.id.name, 'enabled': s.enabled, 'order': s.order},
      ],
    });
    if (saved) _set(dirty: false);
    return saved;
  }

  Future<bool> save(String name, Map<String, Object> args) async {
    if (state.busy) return false;
    _set(busy: true);
    final result = await _action(name, args);
    if (isClosed) return false;
    return result.fold(
      (f) {
        _set(busy: false, failure: f);
        return false;
      },
      (_) {
        _set(busy: false);
        return true;
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _services?.cancel();
    return super.close();
  }
}
