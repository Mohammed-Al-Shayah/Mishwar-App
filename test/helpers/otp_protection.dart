import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/repositories/otp_protection_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/get_otp_protection.dart';

GetOtpProtection protection({int remaining = 0}) =>
    GetOtpProtection(_Protection(remaining));

class _Protection implements OtpProtectionRepository {
  _Protection(this.remaining);
  final int remaining;
  @override
  Future<Either<Failure, OtpProtection>> read(String phone) async =>
      Right(OtpProtection(remaining: remaining));
}
