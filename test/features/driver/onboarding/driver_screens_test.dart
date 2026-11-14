import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/submit_driver_application.dart';
import 'package:mishwar/features/common/user/domain/usecases/upload_license_photo.dart';
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_onboarding_screen.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_pending_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements DriverRepository {}

class MockSession extends MockCubit<SessionState> implements SessionCubit {}

class MockSignOut extends Mock implements SignOut {}

Widget wrap(
  Widget child, {
  Locale locale = const Locale('ar'),
  bool dark = false,
  double scale = 1,
}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (_, _) => MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  ),
);
void main() {
  final l10n = AppLocalizationsAr();
  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('empty onboarding shows inline errors only after submit', (
    tester,
  ) async {
    size(tester);
    final repository = MockRepository();
    final cubit = DriverOnboardingCubit(
      UploadLicensePhoto(repository),
      SubmitDriverApplication(repository),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      wrap(
        BlocProvider.value(
          value: cubit,
          child: const DriverOnboardingScreen(uid: 'u'),
        ),
      ),
    );
    expect(find.text(l10n.errorVehicleLength), findsNothing);
    await tester.tap(find.byKey(const Key('driver_submit')));
    await tester.pump();
    expect(cubit.state.errors.length, 5);
    expect(find.text(l10n.errorVehicleLength), findsNWidgets(3));
    expect(find.text(l10n.errorPlateFormat), findsOneWidget);
    expect(find.text(l10n.errorPhotoRequired), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final status in [
    DriverStatus.pending,
    DriverStatus.rejected,
    DriverStatus.suspended,
  ]) {
    for (final language in ['ar', 'en']) {
      testWidgets('pending screen $status $language renders at 1.3 scale', (
        tester,
      ) async {
        size(tester);
        final session = MockSession();
        final driver = DriverEntity(
          id: 'u',
          status: status,
          isOnline: false,
          rejectionReason: status == DriverStatus.rejected
              ? 'Please upload a clearer license'
              : null,
          vehicle: const VehicleEntity(
            type: VehicleType.comfort,
            make: 'Toyota',
            model: 'Corolla',
            color: 'White',
            plate: '12-34567',
          ),
        );
        final user = UserEntity(
          id: 'u',
          name: 'Driver',
          phone: '+962791234567',
          createdAt: DateTime.utc(2026),
          role: UserRole.driver,
        );
        whenListen(
          session,
          const Stream<SessionState>.empty(),
          initialState: SessionReady(user, driver: driver),
        );
        final home = HomeCubit(MockSignOut());
        addTearDown(home.close);
        await tester.pumpWidget(
          wrap(
            MultiBlocProvider(
              providers: [
                BlocProvider<SessionCubit>.value(value: session),
                BlocProvider<HomeCubit>.value(value: home),
              ],
              child: const DriverPendingScreen(),
            ),
            locale: Locale(language),
            dark: true,
            scale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        final translations = await AppLocalizations.delegate.load(
          Locale(language),
        );
        expect(
          find.text(switch (status) {
            DriverStatus.rejected => translations.driverRejectedTitle,
            DriverStatus.suspended => translations.driverSuspendedTitle,
            _ => translations.driverPendingTitle,
          }),
          findsOneWidget,
        );
        expect(
          find.text(translations.driverResubmit),
          status == DriverStatus.rejected ? findsOneWidget : findsNothing,
        );
        expect(find.text('12-34567'), findsOneWidget);
        if (status == DriverStatus.rejected) {
          expect(find.text(driver.rejectionReason!), findsOneWidget);
        }
        expect(find.byKey(const Key('sign_out')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
