import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/error/exceptions.dart';
import 'package:mishwar/features/common/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockCredential extends Mock implements PhoneAuthCredential {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  const phone = '+962791234567';
  setUpAll(() {
    registerFallbackValue(MockCredential());
    registerFallbackValue((PhoneAuthCredential _) {});
    registerFallbackValue((FirebaseAuthException _) {});
    registerFallbackValue((String _, int? _) {});
    registerFallbackValue((String _) {});
  });
  late MockFirebaseAuth auth;
  late AuthRemoteDataSourceImpl source;
  late Invocation request;
  setUp(() {
    auth = MockFirebaseAuth();
    source = AuthRemoteDataSourceImpl(auth);
    when(
      () => auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: any(named: 'verificationCompleted'),
        verificationFailed: any(named: 'verificationFailed'),
        codeSent: any(named: 'codeSent'),
        codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        timeout: const Duration(seconds: 60),
        forceResendingToken: any(named: 'forceResendingToken'),
      ),
    ).thenAnswer((invocation) async {
      request = invocation;
    });
  });
  testWidgets('codeSent completes and forwards resend token', (tester) async {
    const previous = OtpSession(phone: phone, resendToken: 7);
    final future = source.sendOtp(phone, resendFrom: previous);
    expect(request.namedArguments[#forceResendingToken], 7);
    final sent = request.namedArguments[#codeSent]! as PhoneCodeSent;
    sent('verification', 8);
    final session = await future;
    expect(session.verificationId, 'verification');
    expect(session.resendToken, 8);
    expect(session.autoVerified, isFalse);
    await tester.pump(const Duration(seconds: 60));
  });
  testWidgets('verificationFailed wraps SDK exception', (tester) async {
    final future = source.sendOtp(phone);
    final expectation = expectLater(
      future,
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          'too-many-requests',
        ),
      ),
    );
    final failed =
        request.namedArguments[#verificationFailed]! as PhoneVerificationFailed;
    failed(FirebaseAuthException(code: 'too-many-requests'));
    await expectation;
  });
  testWidgets('request deadline completes even without SDK callbacks', (
    tester,
  ) async {
    final future = source.sendOtp(phone);
    final expectation = expectLater(
      future,
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          'session-expired',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 60));
    await expectation;
  });
  test(
    'five invalid codes cannot be retried through a recreated cubit',
    () async {
      const session = OtpSession(phone: phone, verificationId: 'id');
      when(
        () => auth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'invalid-verification-code'));
      for (var attempt = 0; attempt < 5; attempt++) {
        await expectLater(
          source.verifyOtp(session, '000000'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'invalid-verification-code',
            ),
          ),
        );
      }
      await expectLater(
        source.verifyOtp(session, '000000'),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'session-expired'),
        ),
      );
      verify(() => auth.signInWithCredential(any())).called(5);
      const next = OtpSession(phone: phone, verificationId: 'new');
      await expectLater(
        source.verifyOtp(next, '000000'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.code,
            'code',
            'invalid-verification-code',
          ),
        ),
      );
    },
  );
  testWidgets('automatic verification signs in and retains session user', (
    tester,
  ) async {
    final credential = MockCredential();
    final result = MockUserCredential();
    final user = MockUser();
    when(() => user.uid).thenReturn('uid');
    when(() => user.phoneNumber).thenReturn(phone);
    when(() => result.user).thenReturn(user);
    when(
      () => auth.signInWithCredential(credential),
    ).thenAnswer((_) async => result);
    final future = source.sendOtp(phone);
    final completed =
        request.namedArguments[#verificationCompleted]!
            as PhoneVerificationCompleted;
    completed(credential);
    final session = await future;
    expect(session.autoVerified, isTrue);
    expect(source.autoVerifiedUser(session)?.uid, 'uid');
    verify(() => auth.signInWithCredential(credential)).called(1);
  });
}
