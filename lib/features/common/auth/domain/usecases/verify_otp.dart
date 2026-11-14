import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class VerifyOtp implements UseCase<AuthUser, VerifyOtpParams> {
  const VerifyOtp(this._repository);
  final AuthRepository _repository;
  static final _codePattern = RegExp(r'^\d{6}$');
  @override
  Future<Either<Failure, AuthUser>> call(VerifyOtpParams params) async {
    if (params.code.length != 6 || !_codePattern.hasMatch(params.code)) {
      return const Left(
        AuthFailure(
          'invalid-verification-code',
          code: AuthFailureCode.invalidCode,
        ),
      );
    }
    return _repository.verifyOtp(params.session, params.code);
  }
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.session, required this.code});
  final OtpSession session;
  final String code;
  @override
  List<Object?> get props => [session, code];
}
