import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/pricing/domain/fare_calculator.dart';

class AdminState extends Equatable {
  const AdminState({
    this.section = AdminSection.overview,
    this.data,
    this.loading = true,
    this.busy = false,
    this.failure,
    this.status,
    this.search = '',
    this.page = 0,
    this.from,
    this.to,
    this.licenseUrl,
    this.saved = false,
  });
  final AdminSection section;
  final AdminData? data;
  final bool loading;
  final bool busy;
  final bool saved;
  final Failure? failure;
  final String? status;
  final String? licenseUrl;
  final String search;
  final int page;
  final DateTime? from;
  final DateTime? to;
  List<AdminEntry> get entries => (data?.entries ?? [])
      .where(
        (e) => '${e.name} ${e.phone} ${e.plate}'.toLowerCase().contains(
          search.toLowerCase(),
        ),
      )
      .toList();
  @override
  List<Object?> get props => [
    section,
    data,
    loading,
    busy,
    failure,
    status,
    search,
    page,
    from,
    to,
    licenseUrl,
    saved,
  ];
}

@injectable
class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._watch, this._load, this._action, this._license, this._fare)
    : super(const AdminState());
  final WatchAdminData _watch;
  final LoadAdminPage _load;
  final AdminAction _action;
  final LoadAdminLicense _license;
  final FareCalculator _fare;
  StreamSubscription<dynamic>? _subscription;
  final _cursors = <String?>[null];
  String? _rideId;
  int _generation = 0;
  int _licenseGeneration = 0;

  void _set({
    AdminData? data,
    bool? loading,
    bool? busy,
    Failure? failure,
    String? search,
    String? licenseUrl,
    bool saved = false,
  }) => emit(
    AdminState(
      section: state.section,
      data: data ?? state.data,
      loading: loading ?? state.loading,
      busy: busy ?? state.busy,
      failure: failure,
      status: state.status,
      search: search ?? state.search,
      page: state.page,
      from: state.from,
      to: state.to,
      licenseUrl: licenseUrl ?? state.licenseUrl,
      saved: saved,
    ),
  );

  Future<void> start(AdminSection section, {String? rideId}) async {
    _rideId = rideId;
    final generation = ++_generation;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    _subscription = null;
    _cursors
      ..clear()
      ..add(null);
    final now = DateTime.now();
    emit(
      AdminState(
        section: section,
        status: section == AdminSection.drivers ? 'pending' : null,
        from: section == AdminSection.rides
            ? DateTime(now.year, now.month, now.day)
            : null,
      ),
    );
    if ([AdminSection.drivers, AdminSection.rides].contains(section)) {
      await reload();
      return;
    }
    _subscription = _watch(section).listen(
      (result) {
        if (isClosed || generation != _generation) return;
        result.fold(
          (f) => _set(loading: false, failure: f),
          (data) => _set(data: data, loading: false),
        );
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          _set(loading: false, failure: const ServerFailure('admin-stream'));
        }
      },
    );
  }

  Future<void> reload() async {
    final generation = ++_generation;
    _set(loading: true);
    final result = await _load(
      AdminQuery(
        section: state.section,
        status: state.status,
        from: state.from,
        to: state.to,
        after: _cursors.last,
        rideId: _rideId,
      ),
    );
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => _set(loading: false, failure: f),
      (data) => _set(data: data, loading: false),
    );
  }

  Future<void> filter({String? status, DateTime? from, DateTime? to}) async {
    _rideId = null;
    _cursors
      ..clear()
      ..add(null);
    emit(
      AdminState(section: state.section, status: status, from: from, to: to),
    );
    await reload();
  }

  void search(String text) => _set(search: text);
  Future<void> next() async {
    if (state.loading || state.data?.next == null) return;
    _cursors.add(state.data!.next);
    emit(
      AdminState(
        section: state.section,
        status: state.status,
        from: state.from,
        to: state.to,
        page: _cursors.length - 1,
      ),
    );
    await reload();
  }

  Future<void> previous() async {
    if (state.loading || _cursors.length == 1) return;
    _cursors.removeLast();
    emit(
      AdminState(
        section: state.section,
        status: state.status,
        from: state.from,
        to: state.to,
        page: _cursors.length - 1,
      ),
    );
    await reload();
  }

  Future<void> showLicense(String? path) async {
    final generation = ++_licenseGeneration;
    emit(
      AdminState(
        section: state.section,
        data: state.data,
        loading: state.loading,
        status: state.status,
        page: state.page,
        search: state.search,
        from: state.from,
        to: state.to,
      ),
    );
    if (path == null) return;
    final result = await _license(path);
    if (!isClosed && generation == _licenseGeneration) {
      // A missing photo is not a page error; '' shows the no-photo note.
      result.fold((_) => _set(licenseUrl: ''), (url) => _set(licenseUrl: url));
    }
  }

  Future<bool> act(String name, Map<String, Object> args) async {
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
        _set(busy: false, saved: true);
        if ([
          AdminSection.drivers,
          AdminSection.rides,
        ].contains(state.section)) {
          unawaited(reload());
        }
        return true;
      },
    );
  }

  static int? parseRate(String text) {
    final value = double.tryParse(text.trim());
    if (value == null || !value.isFinite || value <= 0 || value > 50) {
      return null;
    }
    final fils = value * 1000;
    return (fils - fils.round()).abs() < 0.0000001 ? fils.round() : null;
  }

  Money preview(VehicleRates rates) =>
      _fare.compute(rates: rates, distanceMeters: 10000, durationSeconds: 1200);
  @override
  Future<void> close() async {
    _generation++;
    _licenseGeneration++;
    await _subscription?.cancel();
    return super.close();
  }
}

class AdminLoginState extends Equatable {
  const AdminLoginState({this.loading = false, this.failed = false});
  final bool loading;
  final bool failed;
  @override
  List<Object> get props => [loading, failed];
}

@injectable
class AdminLoginCubit extends Cubit<AdminLoginState> {
  AdminLoginCubit(this._signIn, this._signOut) : super(const AdminLoginState());
  final AdminSignIn _signIn;
  final SignOut _signOut;
  Future<void> signIn(String email, String password) async {
    if (state.loading) return;
    emit(const AdminLoginState(loading: true));
    final result = await _signIn(email, password);
    if (!isClosed) emit(AdminLoginState(failed: result.isLeft()));
  }

  Future<void> signOut() async {
    emit(const AdminLoginState(loading: true));
    final result = await _signOut(const NoParams());
    if (!isClosed) emit(AdminLoginState(failed: result.isLeft()));
  }
}
