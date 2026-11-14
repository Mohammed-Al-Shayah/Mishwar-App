import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart';

class RoleState extends Equatable {
  const RoleState({
    this.role,
    this.isLoading = false,
    this.failure,
    this.succeeded = false,
  });
  final UserRole? role;
  final bool isLoading;
  final Failure? failure;
  final bool succeeded;
  @override
  List<Object?> get props => [role, isLoading, failure, succeeded];
}

@injectable
class RoleCubit extends Cubit<RoleState> {
  RoleCubit(this._setRole) : super(const RoleState());
  final SetUserRole _setRole;
  void select(UserRole role) {
    if (!state.isLoading && !state.succeeded) emit(RoleState(role: role));
  }

  Future<void> submit(String uid) async {
    final role = state.role;
    if (role == null || state.isLoading || state.succeeded) return;
    emit(RoleState(role: role, isLoading: true));
    final result = await _setRole(uid, role);
    if (isClosed) return;
    result.fold(
      (failure) => emit(RoleState(role: role, failure: failure)),
      (_) => emit(RoleState(role: role, succeeded: true)),
    );
  }
}
