import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';
import 'package:mishwar/core/widgets/mw_country_chip.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/otp_protection_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/get_otp_protection.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/otp_screen.dart';
import 'package:mishwar/features/common/auth/presentation/screens/phone_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/otp_protection.dart';
import '../../../../widget_test.dart' show harness;

class _Send extends Mock implements SendOtp {}

class _Verify extends Mock implements VerifyOtp {}

class _Locked implements OtpProtectionRepository {
  @override
  Future<Either<Failure, OtpProtection>> read(String phone) async =>
      const Right(OtpProtection(remaining: 900, locked: true));
}

void main() {
  const session = OtpSession(phone: '+970591234567');
  setUpAll(
    () => registerFallbackValue(
      const VerifyOtpParams(session: session, code: '000000'),
    ),
  );
  for (final language in ['ar', 'en']) {
    testWidgets('country sheet and Arabic digits at scale 1.3: $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.localeTestValue = const Locale('ar', 'PS');
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final cubit = PhoneCubit(_Send(), protection());
      await tester.pumpWidget(
        harness(
          BlocProvider.value(value: cubit, child: const PhoneScreen()),
          language: language,
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      expect(cubit.state.country, PhoneCountry.palestine);
      await tester.enterText(find.byType(TextField), '٠٥٩١٢٣٤٥٦٧');
      await tester.pump();
      expect(cubit.state.normalizedPhone, '+970591234567');
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PhoneScreen)),
      )!;
      await tester.tap(find.byType(MwCountryChip));
      await tester.pumpAndSettle();
      expect(find.text(l10n.countryPalestine), findsOneWidget);
      expect(find.text(l10n.countryJordan), findsOneWidget);
      expect(find.text('+970'), findsOneWidget);
      expect(find.text('+962'), findsOneWidget);
      await tester.tap(find.text(l10n.countryJordan));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '٠٧٩١٢٣٤٥٦٧');
      await tester.pump();
      expect(cubit.state.normalizedPhone, '+962791234567');
      expect(tester.takeException(), isNull);
      await cubit.close();
      await tester.pumpWidget(const SizedBox.shrink());
    });
    testWidgets(
      'send lock and exhausted codes show safe copy at scale 1.3: $language',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final verify = _Verify();
        when(() => verify(any())).thenAnswer(
          (_) async => const Left(
            AuthFailure('private', code: AuthFailureCode.invalidCode),
          ),
        );
        final cubit = OtpCubit(
          verify,
          _Send(),
          GetOtpProtection(_Locked()),
          session,
        );
        await tester.pumpWidget(
          harness(
            BlocProvider.value(value: cubit, child: const OtpScreen()),
            language: language,
            textScale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(OtpScreen)),
        )!;
        expect(find.text(l10n.errorTooManyRequests), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.byKey(const Key('otp_resend')))
              .onPressed,
          isNull,
        );
        expect(find.text(l10n.resendCountdown(900)), findsOneWidget);
        for (var n = 0; n < 5; n++) {
          cubit.codeChanged('000000');
          await tester.pumpAndSettle();
        }
        expect(find.text(l10n.otpRequestNew), findsOneWidget);
        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(field.enabled, isFalse);
        }
        expect(find.text('private'), findsNothing);
        expect(tester.takeException(), isNull);
        await cubit.close();
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
