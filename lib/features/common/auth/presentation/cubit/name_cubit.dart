import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart';

@injectable
class NameCubit extends Cubit<SubmissionState> {
  NameCubit(this._createProfile) : super(const SubmissionState());
  final CreateUserProfile _createProfile;
  Future<void> submit(AuthUser user, String first, String last) async {
    if (state.isLoading || state.succeeded) return;
    if (first.trim().isEmpty || last.trim().isEmpty) {
      emit(const SubmissionState(failure: ValidationFailure('name-required')));
      return;
    }
    emit(const SubmissionState(isLoading: true));
    final result = await _createProfile(
      uid: user.uid,
      phone: user.phone ?? '',
      name: '${first.trim()} ${last.trim()}',
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(SubmissionState(failure: failure)),
      (_) => emit(const SubmissionState(succeeded: true)),
    );
  }
}
