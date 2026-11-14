import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SendOtp useCase;
  setUp(() {
    repository = MockAuthRepository();
    useCase = SendOtp(repository);
  });
  for (final phone in [
    '',
    '0791234567',
    '+012345678',
    '+1234567',
    '+1234567890123456',
    '+962791234567\n',
    '+96279 1234567',
    '+٩٦٢٧٩١٢٣٤٥٦٧',
  ]) {
    test('rejects invalid phone: ${phone.length}', () async {
      final result = await useCase(SendOtpParams(phone));
      expect(
        result,
        const Left<Failure, OtpSession>(
          AuthFailure(
            'invalid-phone-number',
            code: AuthFailureCode.invalidPhone,
          ),
        ),
      );
      verifyZeroInteractions(repository);
    });
  }
  test('passes E164 and resend session unchanged', () async {
    const old = OtpSession(phone: '+962791234567', resendToken: 3);
    const session = OtpSession(phone: '+962791234567', verificationId: 'id');
    when(
      () => repository.sendOtp(old.phone, resendFrom: old),
    ).thenAnswer((_) async => const Right(session));
    expect(
      await useCase(SendOtpParams(old.phone, resendFrom: old)),
      const Right<Failure, OtpSession>(session),
    );
    verify(() => repository.sendOtp(old.phone, resendFrom: old)).called(1);
  });
  test('params compare by value', () {
    expect(const SendOtpParams('+12345678'), const SendOtpParams('+12345678'));
  });
}
