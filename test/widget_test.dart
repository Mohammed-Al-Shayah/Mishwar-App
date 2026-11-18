import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/settings/theme_mode_cubit.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_otp_input.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/phone_screen.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/saved_places_mocks.dart' show appConfigCubit;

class MockSendOtp extends Mock implements SendOtp {}

class MockSession extends Mock implements SessionCubit {}

Widget harness(
  Widget child, {
  String language = 'ar',
  bool dark = false,
  double textScale = 1,
}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (_, _) => MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: Locale(language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: child,
  ),
);
void main() {
  setUp(() {});
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('phone validity, $language, dark=$dark at text scale 1.3', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubit = PhoneCubit(MockSendOtp());
        addTearDown(cubit.close);
        await tester.pumpWidget(
          harness(
            BlocProvider.value(value: cubit, child: const PhoneScreen()),
            language: language,
            dark: dark,
            textScale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        final button = find.descendant(
          of: find.byKey(const Key('phone_continue')),
          matching: find.byType(FilledButton),
        );
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.enterText(find.byType(TextField), '0791234567');
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
        await tester.enterText(find.byType(TextField), '071');
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('OTP paste fills six cells and emits one complete code', (
    tester,
  ) async {
    final codes = <String>[];
    await tester.pumpWidget(
      harness(Scaffold(body: MwOtpInput(onChanged: codes.add))),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otp_digit_0')), '123456');
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      final field = tester.widget<TextField>(find.byKey(Key('otp_digit_$i')));
      expect(field.controller!.text, '${i + 1}');
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
    }
    expect(codes, ['123456']);
    expect(tester.takeException(), isNull);
  });
  testWidgets('every failure uses safe localized copy', (tester) async {
    final failures = [
      for (final code in AuthFailureCode.values)
        AuthFailure('RAW_SECRET', code: code),
      const ValidationFailure('name-required'),
      const ValidationFailure('name-length'),
      const NetworkFailure('RAW_SECRET'),
      const ServerFailure('RAW_SECRET'),
    ];
    for (final failure in failures) {
      await tester.pumpWidget(
        harness(
          Builder(builder: (context) => Text(failureMessage(context, failure))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('RAW_SECRET'), findsNothing);
    }
    final l10n = AppLocalizationsAr();
    expect(find.text(l10n.errorGeneric), findsOneWidget);
  });
  testWidgets('loading button replaces label with spinner', (tester) async {
    await tester.pumpWidget(
      harness(
        Scaffold(
          body: MwPrimaryButton(
            label: 'Continue',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
  testWidgets(
    'MishwarApp accepts injected router and session without Firebase',
    (tester) async {
      final session = MockSession();
      when(() => session.state).thenReturn(const SessionSignedOut());
      when(() => session.stream).thenAnswer((_) => const Stream.empty());
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('injected route')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MishwarApp(
          router: router,
          appConfigCubit: appConfigCubit(),
          sessionCubit: session,
          localeCubit: LocaleCubit(await _preferences()),
          themeModeCubit: ThemeModeCubit(await _preferences()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('injected route'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('injected route'))),
        TextDirection.rtl,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}
