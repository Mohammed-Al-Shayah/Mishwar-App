import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SendOtp implements UseCase<OtpSession, SendOtpParams> {
  const SendOtp(this._repository);
  final AuthRepository _repository;
  @override
  Future<Either<Failure, OtpSession>> call(SendOtpParams params) async {
    if (!isSupportedPhone(params.phoneE164)) {
      return const Left(
        AuthFailure('invalid-phone-number', code: AuthFailureCode.invalidPhone),
      );
    }
    return _repository.sendOtp(params.phoneE164, resendFrom: params.resendFrom);
  }
}

class SendOtpParams extends Equatable {
  const SendOtpParams(this.phoneE164, {this.resendFrom});
  final String phoneE164;
  final OtpSession? resendFrom;
  @override
  List<Object?> get props => [phoneE164, resendFrom];
}
