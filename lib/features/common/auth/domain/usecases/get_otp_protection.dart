import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/repositories/otp_protection_repository.dart';

@lazySingleton
class GetOtpProtection {
  const GetOtpProtection(this._repository);
  final OtpProtectionRepository _repository;
  Future<Either<Failure, OtpProtection>> call(String phone) =>
      _repository.read(phone);
}
