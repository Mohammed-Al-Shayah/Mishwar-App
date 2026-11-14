import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';

@injectable
class HomeCubit extends Cubit<SubmissionState> {
  HomeCubit(this._signOut) : super(const SubmissionState());
  final SignOut _signOut;
  Future<void> signOut() async {
    if (state.isLoading) return;
    emit(const SubmissionState(isLoading: true));
    final result = await _signOut(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(SubmissionState(failure: failure)),
      (_) => emit(const SubmissionState(succeeded: true)),
    );
  }
}
