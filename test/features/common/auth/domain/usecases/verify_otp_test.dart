import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const session = OtpSession(phone: '+12345678');
  late MockAuthRepository repository;
  late VerifyOtp useCase;
  setUp(() {
    repository = MockAuthRepository();
    useCase = VerifyOtp(repository);
  });
  for (final code in [
    '',
    '12345',
    '1234567',
    'abcdef',
    '12345 ',
    '123456\n',
    '١٢٣٤٥٦',
  ]) {
    test('rejects invalid code: ${code.length}', () async {
      expect(
        await useCase(VerifyOtpParams(session: session, code: code)),
        const Left<Failure, AuthUser>(
          AuthFailure(
            'invalid-verification-code',
            code: AuthFailureCode.invalidCode,
          ),
        ),
      );
      verifyZeroInteractions(repository);
    });
  }
  test('passes exactly six digits', () async {
    const user = AuthUser(uid: 'uid');
    when(
      () => repository.verifyOtp(session, '012345'),
    ).thenAnswer((_) async => const Right(user));
    expect(
      await useCase(const VerifyOtpParams(session: session, code: '012345')),
      const Right<Failure, AuthUser>(user),
    );
    verify(() => repository.verifyOtp(session, '012345')).called(1);
  });
  test('params compare by session and code', () {
    expect(
      const VerifyOtpParams(session: session, code: '012345'),
      const VerifyOtpParams(session: session, code: '012345'),
    );
  });
}
