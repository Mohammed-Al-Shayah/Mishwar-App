import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/admin/domain/admin_management.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';

class ManagementState extends Equatable {
  const ManagementState({
    this.data,
    this.market = 'JO',
    this.loading = false,
    this.busy = false,
    this.failure,
  });
  final String market;
  final ManagementData? data;
  final bool loading;
  final bool busy;
  final Failure? failure;
  @override
  List<Object?> get props => [market, data, loading, busy, failure];
}

@injectable
class ManagementCubit extends Cubit<ManagementState> {
  ManagementCubit(this._load, this._action) : super(const ManagementState());
  void selectMarket(String market) {
    if (!state.busy && !state.loading) {
      emit(ManagementState(data: state.data, market: market));
    }
  }

  final LoadManagement _load;
  final AdminAction _action;
  Future<void> load() async {
    if (state.loading) return;
    emit(
      ManagementState(market: state.market, data: state.data, loading: true),
    );
    final result = await _load();
    if (isClosed) return;
    result.fold(
      (f) => emit(
        ManagementState(market: state.market, data: state.data, failure: f),
      ),
      (d) => emit(ManagementState(market: state.market, data: d)),
    );
  }

  Future<bool> save(String name, Map<String, Object> args) async {
    if (state.busy || state.loading) return false;
    emit(ManagementState(market: state.market, data: state.data, busy: true));
    final result = await _action(name, {...args, 'market': state.market});
    if (isClosed) return false;
    if (result.isLeft()) {
      emit(
        ManagementState(
          market: state.market,
          data: state.data,
          failure: result.getLeft().toNullable(),
        ),
      );
      return false;
    }
    emit(ManagementState(market: state.market, data: state.data));
    await load();
    return true;
  }
}
