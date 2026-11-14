import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, OtpSession>> sendOtp(
    String phoneE164, {
    OtpSession? resendFrom,
  });
  Future<Either<Failure, AuthUser>> verifyOtp(OtpSession session, String code);
  Future<Either<Failure, Unit>> signOut();
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;
}
