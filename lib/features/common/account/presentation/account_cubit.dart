import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/account/domain/delete_account.dart';
import 'package:mishwar/features/common/account/domain/switch_role.dart';
import 'package:mishwar/features/common/account/domain/update_name.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';

class AccountState extends Equatable {
  const AccountState({this.user, this.driver, this.busy = false, this.failure});
  final UserEntity? user;
  final DriverEntity? driver;
  final bool busy;
  final Failure? failure;
  @override
  List<Object?> get props => [user, driver, busy, failure];
}

@injectable
class AccountCubit extends Cubit<AccountState> {
  AccountCubit(
    this._watchUser,
    this._watchDriver,
    this._updateName,
    this._switchRole,
    this._deleteAccount,
    this._signOut,
  ) : super(const AccountState());
  final WatchUser _watchUser;
  final WatchDriver _watchDriver;
  final UpdateName _updateName;
  final SwitchRole _switchRole;
  final DeleteAccount _deleteAccount;
  final SignOut _signOut;
  StreamSubscription<Either<Failure, UserEntity?>>? _user;
  StreamSubscription<Either<Failure, DriverEntity?>>? _driver;
  int _generation = 0;
  void _emit({
    UserEntity? user,
    DriverEntity? driver,
    bool? busy,
    Failure? failure,
    bool clearDriver = false,
  }) {
    if (isClosed) return;
    emit(
      AccountState(
        user: user ?? state.user,
        driver: clearDriver ? null : driver ?? state.driver,
        busy: busy ?? state.busy,
        failure: failure,
      ),
    );
  }

  Future<void> start(String uid) async {
    final generation = ++_generation;
    await _user?.cancel();
    await _driver?.cancel();
    _driver = null;
    if (isClosed || generation != _generation) return;
    _user = _watchUser(uid).listen(
      (result) => result.fold(
        (failure) => _emit(failure: failure),
        (user) {
          if (isClosed || generation != _generation || user == null) return;
          _emit(user: user, clearDriver: user.role != UserRole.driver);
          if (user.role == UserRole.driver && _driver == null) {
            _driver = _watchDriver(uid).listen(
              (result) => result.fold(
                (failure) => _emit(failure: failure),
                (driver) {
                  if (state.user?.role == UserRole.driver) {
                    _emit(driver: driver, clearDriver: driver == null);
                  }
                },
              ),
            );
          } else if (user.role != UserRole.driver) {
            unawaited(_driver?.cancel());
            _driver = null;
          }
        },
      ),
    );
  }

  Future<bool> _action(Future<Either<Failure, Unit>> Function() action) async {
    if (state.busy || isClosed) return false;
    _emit(busy: true);
    final result = await action();
    if (isClosed) return result.isRight();
    result.fold(
      (failure) => _emit(busy: false, failure: failure),
      (_) => _emit(busy: false),
    );
    return result.isRight();
  }

  Future<bool> updateName(String name) =>
      _action(() => _updateName(state.user!.id, name));
  Future<bool> switchRole(UserRole role) => _action(() => _switchRole(role));
  Future<bool> signOut() => _action(() => _signOut(const NoParams()));
  Future<bool> deleteAccount() => _action(() async {
    final result = await _deleteAccount();
    if (result.isLeft()) return result;
    return _signOut(const NoParams());
  });
  @override
  Future<void> close() async {
    _generation++;
    await _user?.cancel();
    await _driver?.cancel();
    return super.close();
  }
}
