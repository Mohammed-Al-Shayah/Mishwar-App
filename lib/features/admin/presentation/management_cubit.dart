import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';

class ManagementState extends Equatable {
  const ManagementState({
    this.data,
    this.loading = false,
    this.busy = false,
    this.failure,
  });
  final ManagementData? data;
  final bool loading;
  final bool busy;
  final Failure? failure;
  @override
  List<Object?> get props => [data, loading, busy, failure];
}

@injectable
class ManagementCubit extends Cubit<ManagementState> {
  ManagementCubit(this._load, this._action) : super(const ManagementState());
  final LoadManagement _load;
  final AdminAction _action;
  Future<void> load() async {
    if (state.loading) return;
    emit(ManagementState(data: state.data, loading: true));
    final result = await _load();
    if (isClosed) return;
    result.fold(
      (f) => emit(ManagementState(data: state.data, failure: f)),
      (d) => emit(ManagementState(data: d)),
    );
  }

  Future<bool> save(String name, Map<String, Object> args) async {
    if (state.busy || state.loading) return false;
    emit(ManagementState(data: state.data, busy: true));
    final result = await _action(name, args);
    if (isClosed) return false;
    if (result.isLeft()) {
      emit(
        ManagementState(
          data: state.data,
          failure: result.getLeft().toNullable(),
        ),
      );
      return false;
    }
    emit(ManagementState(data: state.data));
    await load();
    return true;
  }
}
