import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/exceptions.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mishwar/features/common/auth/data/datasources/otp_protection_store.dart';
import 'package:mishwar/features/common/auth/data/repositories/auth_repository_impl.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockProtectionStore extends Mock implements OtpProtectionStore {}

void main() {
  const phone = '+962791234567';
  const session = OtpSession(phone: phone, verificationId: 'verification');
  const user = AuthUser(uid: 'uid', phone: phone);
  late MockRemote remote;
  late AuthRepositoryImpl repository;
  setUp(() {
    remote = MockRemote();
    final protection = MockProtectionStore();
    when(() => protection.reserve(any())).thenAnswer((_) async {});
    repository = AuthRepositoryImpl(remote, protection);
  });
  test('send OTP and resend success', () async {
    when(
      () => remote.sendOtp(phone, resendFrom: session),
    ).thenAnswer((_) async => session);
    expect(
      await repository.sendOtp(phone, resendFrom: session),
      const Right<Failure, OtpSession>(session),
    );
    verify(() => remote.sendOtp(phone, resendFrom: session)).called(1);
  });
  test('verify success', () async {
    when(() => remote.autoVerifiedUser(session)).thenReturn(null);
    when(
      () => remote.verifyOtp(session, '123456'),
    ).thenAnswer((_) async => user);
    expect(
      await repository.verifyOtp(session, '123456'),
      const Right<Failure, AuthUser>(user),
    );
  });
  test('auto verified session short circuits manual verification', () async {
    const automatic = OtpSession(phone: phone, autoVerified: true);
    when(() => remote.autoVerifiedUser(automatic)).thenReturn(user);
    expect(
      await repository.verifyOtp(automatic, '123456'),
      const Right<Failure, AuthUser>(user),
    );
    verifyNever(() => remote.verifyOtp(automatic, '123456'));
  });
  test('auto retrieval after codeSent also short circuits', () async {
    when(() => remote.autoVerifiedUser(session)).thenReturn(user);
    expect(
      await repository.verifyOtp(session, '123456'),
      const Right<Failure, AuthUser>(user),
    );
    verifyNever(() => remote.verifyOtp(session, '123456'));
  });
  test('sign out succeeds', () async {
    when(remote.signOut).thenAnswer((_) async {});
    expect(await repository.signOut(), const Right<Failure, Unit>(unit));
  });
  test('current user and auth state', () async {
    when(() => remote.currentUser).thenReturn(user);
    when(
      remote.authStateChanges,
    ).thenAnswer((_) => Stream.fromIterable([null, user, null]));
    expect(repository.currentUser, user);
    expect(await repository.authStateChanges().toList(), [null, user, null]);
  });
  const codes = {
    'invalid-phone-number': AuthFailureCode.invalidPhone,
    'invalid-verification-code': AuthFailureCode.invalidCode,
    'session-expired': AuthFailureCode.codeExpired,
    'too-many-requests': AuthFailureCode.tooManyRequests,
    'network-request-failed': AuthFailureCode.network,
    'quota-exceeded': AuthFailureCode.quotaExceeded,
    'future-code': AuthFailureCode.unknown,
  };
  for (final entry in codes.entries) {
    test('maps ${entry.key} on all future operations', () async {
      final error = AuthException('sdk-log', code: entry.key);
      when(() => remote.sendOtp(phone)).thenThrow(error);
      when(() => remote.autoVerifiedUser(session)).thenReturn(null);
      when(() => remote.verifyOtp(session, '123456')).thenThrow(error);
      when(remote.signOut).thenThrow(error);
      final failure = AuthFailure('sdk-log', code: entry.value);
      expect(
        await repository.sendOtp(phone),
        Left<Failure, OtpSession>(failure),
      );
      expect(
        await repository.verifyOtp(session, '123456'),
        Left<Failure, AuthUser>(failure),
      );
      expect(await repository.signOut(), Left<Failure, Unit>(failure));
    });
  }
  test('unexpected errors never escape future operations', () async {
    final error = StateError('unexpected');
    when(() => remote.sendOtp(phone)).thenThrow(error);
    when(() => remote.autoVerifiedUser(session)).thenReturn(null);
    when(() => remote.verifyOtp(session, '123456')).thenThrow(error);
    when(remote.signOut).thenThrow(error);
    final failure = UnexpectedFailure(error.toString());
    expect(await repository.sendOtp(phone), Left<Failure, OtpSession>(failure));
    expect(
      await repository.verifyOtp(session, '123456'),
      Left<Failure, AuthUser>(failure),
    );
    expect(await repository.signOut(), Left<Failure, Unit>(failure));
  });
  test('getter and stream errors are contained as signed out', () async {
    when(() => remote.currentUser).thenThrow(StateError('unexpected'));
    when(
      remote.authStateChanges,
    ).thenAnswer((_) => Stream<AuthUser?>.error(StateError('unexpected')));
    expect(repository.currentUser, isNull);
    expect(await repository.authStateChanges().toList(), [null]);
  });
  test('failure equality includes code', () {
    expect(
      const AuthFailure('same', code: AuthFailureCode.network),
      isNot(const AuthFailure('same')),
    );
  });
}
