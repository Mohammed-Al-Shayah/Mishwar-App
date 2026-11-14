import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/name_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/role_cubit.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart';
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockSendOtp extends Mock implements SendOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockCreateProfile extends Mock implements CreateUserProfile {}

class MockSetRole extends Mock implements SetUserRole {}

void main() {
  late MockSendOtp send;
  late MockVerifyOtp verifyOtp;
  late MockCreateProfile create;
  late MockSetRole setRole;
  const session = OtpSession(phone: '+962791234567', verificationId: 'first');
  const user = AuthUser(uid: 'u', phone: '+962791234567');
  setUpAll(() {
    registerFallbackValue(const SendOtpParams('+962791234567'));
    registerFallbackValue(
      const VerifyOtpParams(session: session, code: '123456'),
    );
  });
  setUp(() {
    send = MockSendOtp();
    verifyOtp = MockVerifyOtp();
    create = MockCreateProfile();
    setRole = MockSetRole();
  });
  for (final input in ['0791234567', '791234567']) {
    blocTest<PhoneCubit, PhoneState>(
      'normalizes $input and sends OTP',
      build: () {
        when(() => send(any())).thenAnswer((_) async => const Right(session));
        return PhoneCubit(send);
      },
      act: (cubit) async {
        cubit.phoneChanged(input);
        await cubit.submit();
      },
      expect: () => [
        PhoneState(phone: input),
        PhoneState(phone: input, isLoading: true),
        PhoneState(phone: input, session: session),
      ],
      verify: (cubit) {
        expect(cubit.state.normalizedPhone, session.phone);
        verify(() => send(const SendOtpParams('+962791234567'))).called(1);
      },
    );
  }
  for (final input in [
    '',
    '07123',
    '0691234567',
    '07912345678',
    '+962791234567',
    '0791234567\n',
  ]) {
    test('invalid phone is never submitted: ${input.length}', () async {
      final cubit = PhoneCubit(send)..phoneChanged(input);
      await cubit.submit();
      expect(cubit.state.normalizedPhone, isNull);
      verifyZeroInteractions(send);
      await cubit.close();
    });
  }
  blocTest<PhoneCubit, PhoneState>(
    'phone failure stays retryable',
    build: () {
      when(
        () => send(any()),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      return PhoneCubit(send);
    },
    act: (cubit) async {
      cubit.phoneChanged('791234567');
      await cubit.submit();
    },
    expect: () => [
      const PhoneState(phone: '791234567'),
      const PhoneState(phone: '791234567', isLoading: true),
      const PhoneState(phone: '791234567', failure: NetworkFailure('offline')),
    ],
  );
  blocTest<OtpCubit, OtpState>(
    'sixth digit auto submits once',
    build: () {
      when(() => verifyOtp(any())).thenAnswer((_) async => const Right(user));
      return OtpCubit(verifyOtp, send, session);
    },
    act: (cubit) async {
      cubit
        ..codeChanged('12345')
        ..codeChanged('123456')
        ..codeChanged('123456');
    },
    expect: () => [
      const OtpState(session: session, code: '12345'),
      const OtpState(session: session, code: '123456'),
      const OtpState(session: session, code: '123456', isLoading: true),
      const OtpState(session: session, code: '123456', succeeded: true),
    ],
    verify: (_) => verify(() => verifyOtp(any())).called(1),
  );
  blocTest<OtpCubit, OtpState>(
    'invalid-code failure is retained for localized rendering',
    build: () {
      when(() => verifyOtp(any())).thenAnswer(
        (_) async => const Left(
          AuthFailure('secret', code: AuthFailureCode.invalidCode),
        ),
      );
      return OtpCubit(verifyOtp, send, session);
    },
    act: (cubit) => cubit.codeChanged('000000'),
    expect: () => [
      const OtpState(session: session, code: '000000'),
      const OtpState(session: session, code: '000000', isLoading: true),
      const OtpState(
        session: session,
        code: '000000',
        failure: AuthFailure('secret', code: AuthFailureCode.invalidCode),
      ),
    ],
  );
  test(
    'resend waits 30 seconds, replaces session and cancels timer',
    () {
      fakeAsync((async) {
        const next = OtpSession(phone: '+962791234567', verificationId: 'next');
        when(() => send(any())).thenAnswer((_) async => const Right(next));
        final cubit = OtpCubit(verifyOtp, send, session);
        unawaited(cubit.resend());
        async.flushMicrotasks();
        verifyZeroInteractions(send);
        async.elapse(const Duration(seconds: 29));
        expect(cubit.state.remaining, 1);
        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.remaining, 0);
        unawaited(cubit.resend());
        async.flushMicrotasks();
        expect(cubit.state.session, next);
        expect(cubit.state.remaining, 30);
        verify(
          () => send(const SendOtpParams('+962791234567', resendFrom: session)),
        ).called(1);
        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(async.periodicTimerCount, 0);
      });
    },
  );
  blocTest<NameCubit, SubmissionState>(
    'trims both names before creating a profile',
    build: () {
      when(
        () => create(uid: 'u', phone: user.phone!, name: 'Test User'),
      ).thenAnswer((_) async => const Right(unit));
      return NameCubit(create);
    },
    act: (cubit) => cubit.submit(user, ' Test ', ' User '),
    expect: () => [
      const SubmissionState(isLoading: true),
      const SubmissionState(succeeded: true),
    ],
  );
  blocTest<NameCubit, SubmissionState>(
    'requires both name fields',
    build: () => NameCubit(create),
    act: (cubit) => cubit.submit(user, '', 'User'),
    expect: () => [
      const SubmissionState(failure: ValidationFailure('name-required')),
    ],
    verify: (_) => verifyZeroInteractions(create),
  );
  blocTest<NameCubit, SubmissionState>(
    'profile failure is retryable',
    build: () {
      when(
        () => create(uid: 'u', phone: user.phone!, name: 'Test User'),
      ).thenAnswer((_) async => const Left(ServerFailure('denied')));
      return NameCubit(create);
    },
    act: (cubit) => cubit.submit(user, 'Test', 'User'),
    expect: () => [
      const SubmissionState(isLoading: true),
      const SubmissionState(failure: ServerFailure('denied')),
    ],
  );
  blocTest<RoleCubit, RoleState>(
    'selects and persists role',
    build: () {
      when(
        () => setRole('u', UserRole.driver),
      ).thenAnswer((_) async => const Right(unit));
      return RoleCubit(setRole);
    },
    act: (cubit) async {
      cubit.select(UserRole.driver);
      await cubit.submit('u');
    },
    expect: () => [
      const RoleState(role: UserRole.driver),
      const RoleState(role: UserRole.driver, isLoading: true),
      const RoleState(role: UserRole.driver, succeeded: true),
    ],
  );
  blocTest<RoleCubit, RoleState>(
    'does not save without selection',
    build: () => RoleCubit(setRole),
    act: (cubit) => cubit.submit('u'),
    expect: () => <RoleState>[],
    verify: (_) => verifyZeroInteractions(setRole),
  );
  blocTest<RoleCubit, RoleState>(
    'role failure is retryable',
    build: () {
      when(
        () => setRole('u', UserRole.rider),
      ).thenAnswer((_) async => const Left(ServerFailure('permission-denied')));
      return RoleCubit(setRole);
    },
    act: (cubit) async {
      cubit.select(UserRole.rider);
      await cubit.submit('u');
    },
    expect: () => [
      const RoleState(role: UserRole.rider),
      const RoleState(role: UserRole.rider, isLoading: true),
      const RoleState(
        role: UserRole.rider,
        failure: ServerFailure('permission-denied'),
      ),
    ],
  );
}
