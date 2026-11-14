import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/exceptions.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (error) {
      return Left(
        AuthFailure(
          error.message,
          code: AuthFailureCode.fromFirebaseCode(error.code),
        ),
      );
      // The repository boundary also contains SDK and platform errors.
    } on Object catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, OtpSession>> sendOtp(
    String phoneE164, {
    OtpSession? resendFrom,
  }) => _guard(() => _remote.sendOtp(phoneE164, resendFrom: resendFrom));
  @override
  Future<Either<Failure, AuthUser>> verifyOtp(
    OtpSession session,
    String code,
  ) => _guard(() async {
    final verified = _remote.autoVerifiedUser(session);
    if (verified != null) return verified;
    return _remote.verifyOtp(session, code);
  });
  @override
  Future<Either<Failure, Unit>> signOut() => _guard(() async {
    await _remote.signOut();
    return unit;
  });
  @override
  AuthUser? get currentUser {
    try {
      return _remote.currentUser;
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    try {
      await for (final user in _remote.authStateChanges()) {
        yield user;
      }
    } on Object catch (_) {
      yield null;
    }
  }
}
