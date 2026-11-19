import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mishwar/features/common/auth/data/datasources/otp_protection_store.dart';
import 'package:mishwar/features/common/auth/data/repositories/auth_repository_impl.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/get_otp_protection.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/otp_protection.dart';

class _Remote extends Mock implements AuthRemoteDataSource {}

class _Verify extends Mock implements VerifyOtp {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const phone = '+970591234567';
  const session = OtpSession(phone: phone, verificationId: 'first');
  setUpAll(
    () => registerFallbackValue(
      const VerifyOtpParams(session: session, code: '000000'),
    ),
  );
  test(
    'shared guard escalates 60/120/300, locks fifth send and survives restart per number',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      fakeAsync((async) {
        final remote = _Remote();
        when(
          () => remote.sendOtp(any(), resendFrom: any(named: 'resendFrom')),
        ).thenAnswer(
          (invocation) async =>
              OtpSession(phone: invocation.positionalArguments.first as String),
        );
        final store = OtpProtectionStore(prefs);
        final send = SendOtp(AuthRepositoryImpl(remote, store));
        final get = GetOtpProtection(store);
        final entry = PhoneCubit(send, get)..phoneChanged(phone);
        unawaited(entry.submit());
        async.flushMicrotasks();
        expect(entry.state.remaining, 60);
        final otp = OtpCubit(_Verify(), send, get, entry.state.session!);
        async.flushMicrotasks();
        for (final next in [120, 300, 300, 900]) {
          unawaited(otp.resend()); // Cooldown cannot be bypassed.
          async
            ..flushMicrotasks()
            ..elapse(Duration(seconds: otp.state.remaining));
          unawaited(otp.resend());
          async.flushMicrotasks();
          expect(otp.state.remaining, next);
        }
        expect(otp.state.locked, isTrue);
        verify(
          () => remote.sendOtp(phone, resendFrom: any(named: 'resendFrom')),
        ).called(5);
        // Recreate both store and screen as on a process restart.
        final restarted = OtpProtectionStore(prefs);
        final newEntry = PhoneCubit(send, GetOtpProtection(restarted))
          ..phoneChanged(phone);
        async.flushMicrotasks();
        expect(newEntry.state.locked, isTrue);
        unawaited(newEntry.submit());
        async.flushMicrotasks();
        newEntry.phoneChanged('+962791234567');
        async.flushMicrotasks();
        expect(newEntry.state.remaining, 0);
        newEntry.phoneChanged(phone);
        async.flushMicrotasks();
        expect(newEntry.state.remaining, 900);
        async.elapse(const Duration(seconds: 899));
        expect(newEntry.state.remaining, 1);
        async.elapse(const Duration(seconds: 1));
        expect(newEntry.state.locked, isFalse);
        unawaited(newEntry.submit());
        async.flushMicrotasks();
        expect(newEntry.state.remaining, 60);
        expect(prefs.getKeys().any((key) => key.contains(phone)), isFalse);
        unawaited(entry.close());
        unawaited(otp.close());
        unawaited(newEntry.close());
        async.flushMicrotasks();
        expect(async.periodicTimerCount, 0);
      });
    },
  );
  test(
    'five wrong codes require new session; network errors do not count',
    () async {
      final verify = _Verify();
      final remote = _Remote();
      when(
        () => remote.sendOtp(phone, resendFrom: session),
      ).thenAnswer((_) async => const OtpSession(phone: phone));
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      fakeAsync((async) {
        final store = OtpProtectionStore(prefs);
        final send = SendOtp(AuthRepositoryImpl(remote, store));
        final cubit = OtpCubit(verify, send, protection(), session);
        async.flushMicrotasks();
        when(
          () => verify(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
        cubit.codeChanged('000000');
        async.flushMicrotasks();
        expect(cubit.state.wrongAttempts, 0);
        when(() => verify(any())).thenAnswer(
          (_) async =>
              const Left(AuthFailure('bad', code: AuthFailureCode.invalidCode)),
        );
        for (var n = 0; n < 5; n++) {
          cubit.codeChanged('000000');
          async.flushMicrotasks();
        }
        expect(cubit.state.needsNewCode, isTrue);
        unawaited(cubit.submit());
        cubit.codeChanged('123456');
        async.flushMicrotasks();
        verifyNever(
          () => verify(const VerifyOtpParams(session: session, code: '123456')),
        );
        unawaited(cubit.resend());
        async.flushMicrotasks();
        expect(cubit.state.needsNewCode, isFalse);
        expect(cubit.state.code, isEmpty);
        unawaited(cubit.close());
        async.flushMicrotasks();
      });
    },
  );
  test('quota errors map to friendly retry failure', () {
    for (final code in ['too-many-requests', 'resource-exhausted']) {
      expect(
        AuthFailureCode.fromFirebaseCode(code),
        AuthFailureCode.tooManyRequests,
      );
    }
  });
}
