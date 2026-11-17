import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/settings/theme_mode_cubit.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/account/presentation/account_cubit.dart';
import 'package:mishwar/features/common/account/presentation/account_screen.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAccountCubit extends Mock implements AccountCubit {}

void main() {
  setUpAll(() async {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final font = FontLoader('IBMPlexSansArabic')
        ..addFont(
          rootBundle.load(
            'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-$weight.ttf',
          ),
        );
      await font.load();
    }
    final icons = FontLoader('PhosphorRegular')
      ..addFont(rootBundle.load('assets/fonts/phosphor/Phosphor.ttf'));
    await icons.load();
  });
  late MockAccountCubit cubit;
  late LocaleCubit locale;
  late ThemeModeCubit theme;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    locale = LocaleCubit(prefs);
    theme = ThemeModeCubit(prefs);
    cubit = MockAccountCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.updateName(any())).thenAnswer((_) async => true);
    when(cubit.deleteAccount).thenAnswer((_) async => true);
    when(cubit.signOut).thenAnswer((_) async => true);
    when(() => cubit.switchRole(UserRole.driver)).thenAnswer((_) async => true);
    when(() => cubit.switchRole(UserRole.rider)).thenAnswer((_) async => true);
  });
  tearDown(() async {
    await locale.close();
    await theme.close();
  });
  Future<void> pump(
    WidgetTester tester, {
    bool driver = false,
    String language = 'en',
    Failure? failure,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final user = UserEntity(
      id: 'u',
      name: 'Test Name',
      phone: '+962790000000',
      createdAt: DateTime.utc(2026),
      role: driver ? UserRole.driver : UserRole.rider,
    );
    when(() => cubit.state).thenReturn(
      AccountState(
        user: user,
        failure: failure,
        driver: driver
            ? const DriverEntity(
                id: 'u',
                status: DriverStatus.approved,
                isOnline: false,
                vehicle: VehicleEntity(
                  type: VehicleType.economy,
                  make: 'Toyota',
                  model: 'Corolla',
                  color: 'White',
                  plate: '12-34567',
                ),
              )
            : null,
      ),
    );
    await locale.setLocale(language);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AccountCubit>.value(value: cubit),
          BlocProvider.value(value: locale),
          BlocProvider.value(value: theme),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => BlocBuilder<LocaleCubit, Locale>(
            builder: (_, value) => MaterialApp(
              theme: AppTheme.light(),
              locale: value,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: AccountScreen(driver: driver),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppLocalizations strings(WidgetTester tester) =>
      tester.element(find.byType(AccountScreen)).l10n;
  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).first;
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final driver in [false, true]) {
    for (final language in ['ar', 'en']) {
      testWidgets('account $driver $language fits at text scale 1.3', (
        tester,
      ) async {
        await pump(tester, driver: driver, language: language);
        final l10n = strings(tester);
        expect(find.text('Test Name'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('+962790000000')).textDirection,
          TextDirection.ltr,
        );
        expect(
          find.text(l10n.accountAppearance),
          driver ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(l10n.accountVehicle),
          driver ? findsOneWidget : findsNothing,
        );
        expect(
          Theme.of(tester.element(find.byType(MwListRow).first)).brightness,
          driver ? Brightness.dark : Brightness.light,
        );
        expect(find.text(l10n.accountTerms), findsNothing);
        expect(find.text(l10n.accountPrivacy), findsNothing);
        if (driver) {
          await tapText(tester, l10n.accountVehicle);
          // The row subtitle also names the car; check the opened sheet.
          final sheet = find.descendant(
            of: find.byType(BottomSheet),
            matching: find.textContaining('Toyota Corolla'),
          );
          expect(sheet, findsOneWidget);
          expect(find.byType(TextField), findsNothing);
          Navigator.of(tester.element(sheet)).pop();
          await tester.pumpAndSettle();
        }
        await tapText(tester, driver ? l10n.accountRide : l10n.accountDrive);
        await tapText(tester, l10n.accountConfirm);
        verify(
          () => cubit.switchRole(driver ? UserRole.rider : UserRole.driver),
        ).called(1);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('name save gates invalid input and submits trimmed value', (
    tester,
  ) async {
    await pump(tester);
    final l10n = strings(tester);
    await tapText(tester, l10n.accountProfile);
    await tester.enterText(find.byType(TextField), ' a ');
    await tester.pump();
    expect(
      tester.widget<MwPrimaryButton>(find.byType(MwPrimaryButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'x' * 41);
    await tester.pump();
    expect(
      tester.widget<MwPrimaryButton>(find.byType(MwPrimaryButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '  New Name  ');
    await tester.pump();
    await tapText(tester, l10n.accountSave);
    verify(() => cubit.updateName('New Name')).called(1);
  });
  for (final language in ['ar', 'en']) {
    testWidgets('delete has two steps and localized typed gating $language', (
      tester,
    ) async {
      await pump(tester, language: language);
      final l10n = strings(tester);
      await tapText(tester, l10n.accountDelete);
      expect(find.text(l10n.accountDeleteWarning), findsOneWidget);
      verifyNever(cubit.deleteAccount);
      await tapText(tester, l10n.accountConfirm);
      expect(
        tester.widget<MwPrimaryButton>(find.byType(MwPrimaryButton)).onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pump();
      expect(
        tester.widget<MwPrimaryButton>(find.byType(MwPrimaryButton)).onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), l10n.accountDeleteWord);
      await tester.pump();
      await tester.tap(find.byType(MwPrimaryButton));
      await tester.pumpAndSettle();
      verify(cubit.deleteAccount).called(1);
    });
  }
  testWidgets('language and appearance sheets update settings', (tester) async {
    await pump(tester);
    var l10n = strings(tester);
    await tapText(tester, l10n.accountLanguage);
    await tapText(tester, l10n.accountArabic);
    expect(locale.state.languageCode, 'ar');
    l10n = strings(tester);
    await tapText(tester, l10n.accountAppearance);
    await tapText(tester, l10n.accountDark);
    expect(theme.state, ThemeMode.dark);
  });
  testWidgets('about shows the installed package version', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Mishwar',
      packageName: 'com.shayah.mishwar',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
    await pump(tester);
    await tapText(tester, strings(tester).accountAbout);
    expect(find.textContaining('1.2.3 (42)'), findsOneWidget);
  });
  testWidgets('busy message and signout confirmation', (tester) async {
    await pump(tester, failure: const ServerFailure('account-busy'));
    final l10n = strings(tester);
    expect(find.text(l10n.accountBusy), findsOneWidget);
    await tapText(tester, l10n.signOutLabel);
    verifyNever(cubit.signOut);
    await tapText(tester, l10n.accountCancel);
    verifyNever(cubit.signOut);
    await tapText(tester, l10n.signOutLabel);
    await tapText(tester, l10n.accountConfirm);
    verify(cubit.signOut).called(1);
  });
}
