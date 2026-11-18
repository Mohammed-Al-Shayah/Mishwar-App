import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/settings/theme_mode_cubit.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';
import 'package:mishwar/features/common/account/domain/delete_account.dart';
import 'package:mishwar/features/common/account/domain/switch_role.dart';
import 'package:mishwar/features/common/account/domain/update_name.dart';
import 'package:mishwar/features/common/account/presentation/account_cubit.dart';
import 'package:mishwar/features/common/account/presentation/account_screen.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/name_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/role_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/splash_screen.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/unregister_push_token.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/support/domain/support_repository.dart';
import 'package:mishwar/features/common/support/domain/support_usecases.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart';
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/driver/offer/driver_offer_bloc_test.dart'
    show MockOfferBloc;
import '../features/driver/presence/driver_home_screen_test.dart'
    show MockPresenceBloc, homeEarnings;
import '../helpers/location_mocks.dart';
import '../helpers/ride_mocks.dart';
import '../helpers/saved_places_mocks.dart';

class MockDriverRepository extends Mock implements DriverRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockWatchAuth extends Mock implements WatchAuthState {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUnregisterPushToken extends Mock implements UnregisterPushToken {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockSupportRepository extends Mock implements SupportRepository {}

void main() {
  setUp(registerSavedPlaces);
  setUp(() {
    final support = MockSupportRepository();
    when(
      () => support.watchTickets(uid: any(named: 'uid')),
    ).thenAnswer((_) => Stream.value(const Right([])));
    getIt.registerFactory(() => SupportListCubit(WatchSupportTickets(support)));
  });
  setUpAll(() {
    registerFallbackValue(const GoOnlinePressed());
    registerFallbackValue(const offer.Started('u'));
  });
  for (final role in UserRole.values) {
    testWidgets('complete sign-in, name, ${role.name} and sign-out flow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = MockAuthRepository();
      final unregister = MockUnregisterPushToken();
      when(
        () => unregister(const NoParams()),
      ).thenAnswer((_) async => const Right(unit));
      final users = MockUserRepository();
      final authEvents =
          StreamController<Either<Failure, AuthUser?>>.broadcast();
      final watchAuth = MockWatchAuth();
      final profiles =
          StreamController<Either<Failure, UserEntity?>>.broadcast();
      const authUser = AuthUser(uid: 'u', phone: '+962791234567');
      const otp = OtpSession(phone: '+962791234567', verificationId: 'test');
      final profile = UserEntity(
        id: 'u',
        name: 'Test User',
        phone: otp.phone,
        createdAt: DateTime.utc(2026),
      );
      when(
        () => watchAuth(const NoParams()),
      ).thenAnswer((_) => authEvents.stream);
      when(() => users.watchUser('u')).thenAnswer((_) => profiles.stream);
      when(
        () => auth.sendOtp(otp.phone),
      ).thenAnswer((_) async => const Right(otp));
      when(() => auth.verifyOtp(otp, '123456')).thenAnswer((_) async {
        authEvents.add(const Right(authUser));
        return const Right(authUser);
      });
      when(
        () =>
            users.createProfile(uid: 'u', phone: otp.phone, name: 'Test User'),
      ).thenAnswer((_) async {
        profiles.add(Right(profile));
        return const Right(unit);
      });
      when(() => users.setRole('u', role)).thenAnswer((_) async {
        profiles.add(Right(profile.copyWith(role: role)));
        return const Right(unit);
      });
      when(auth.signOut).thenAnswer((_) async {
        authEvents.add(const Right(null));
        return const Right(unit);
      });
      final send = SendOtp(auth);
      final verifyOtp = VerifyOtp(auth);
      getIt
        ..registerFactory(() => PhoneCubit(send))
        ..registerFactoryParam<OtpCubit, OtpSession, dynamic>(
          (session, _) => OtpCubit(verifyOtp, send, session),
        )
        ..registerFactory(() => NameCubit(CreateUserProfile(users)))
        ..registerFactory(() => RoleCubit(SetUserRole(users)))
        ..registerFactory(() => HomeCubit(SignOut(auth, unregister)));
      final presence = MockPresenceBloc();
      whenListen(
        presence,
        const Stream<DriverPresenceState>.empty(),
        initialState: const DriverPresenceState(),
      );
      getIt
        ..registerFactory<DriverPresenceBloc>(() => presence)
        ..registerFactory<DriverEarningsCubit>(homeEarnings);
      final offerBloc = MockOfferBloc();
      whenListen(
        offerBloc,
        const Stream<offer.DriverOfferState>.empty(),
        initialState: const offer.DriverOfferState(),
      );
      getIt.registerFactory<offer.DriverOfferBloc>(() => offerBloc);
      final location = MockLocationRepository();
      when(location.checkPermission).thenAnswer(
        (_) async => const Right(LocationPermissionStatus.deniedForever),
      );
      getIt.registerFactory(() => riderCubit(location));
      final drivers = MockDriverRepository();
      when(() => drivers.watchDriver('u')).thenAnswer(
        (_) => Stream.value(
          const Right(
            DriverEntity(
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
            ),
          ),
        ),
      );
      final session = SessionCubit(
        watchAuth,
        WatchUser(users),
        WatchDriver(drivers),
      );
      final accountRepository = MockAccountRepository();
      final nextRole = role == UserRole.rider
          ? UserRole.driver
          : UserRole.rider;
      when(() => accountRepository.switchRole(nextRole)).thenAnswer((_) async {
        profiles.add(Right(profile.copyWith(role: nextRole)));
        return const Right(unit);
      });
      getIt.registerFactory(
        () => AccountCubit(
          WatchUser(users),
          WatchDriver(drivers),
          UpdateName(accountRepository),
          SwitchRole(accountRepository),
          DeleteAccount(accountRepository),
          SignOut(auth, unregister),
        ),
      );
      addTearDown(() async {
        await session.close();
        await authEvents.close();
        await profiles.close();
        await getIt.reset();
      });
      final refresh = SessionRouterRefresh(session.stream);
      getIt.registerSingleton<WatchActiveRideId>(emptyActiveRideWatch());
      final router = createAppRouter(
        session,
        refresh,
        riderMapBuilder: (_) => const MwMapPlaceholder(),
        driverMapBuilder: (_) => const MwMapPlaceholder(),
      );
      addTearDown(() {
        router.dispose();
        refresh.dispose();
      });
      await tester.pumpWidget(
        MishwarApp(
          sessionCubit: session,
          router: router,
          localeCubit: LocaleCubit(await _preferences()),
          themeModeCubit: ThemeModeCubit(await _preferences()),
        ),
      );
      expect(find.byType(SplashScreen), findsOneWidget);
      authEvents.add(const Right(null));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0791234567');
      await tester.pump();
      await tester.tap(find.byKey(const Key('phone_continue')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('otp_digit_0')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('otp_digit_0')), '123456');
      await tester.pumpAndSettle();
      profiles.add(const Right(null));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('first_name')),
          matching: find.byType(TextField),
        ),
        ' Test ',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('last_name')),
          matching: find.byType(TextField),
        ),
        ' User ',
      );
      await tester.tap(find.byKey(const Key('name_continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('role_${role.name}')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('role_continue')));
      await tester.pumpAndSettle();
      final l10n = AppLocalizationsAr();
      expect(
        find.text(role == UserRole.rider ? l10n.whereTo : l10n.driverOffline),
        role == UserRole.rider ? findsNWidgets(2) : findsOneWidget,
      );
      if (role == UserRole.driver) {
        expect(find.byType(DriverHomeScreen), findsOneWidget);
        final homeContext = tester.element(find.text(l10n.driverOffline));
        expect(Theme.of(homeContext).brightness, Brightness.dark);
      }
      Future<void> openAccount(UserRole currentRole) async {
        await tester.tap(
          currentRole == UserRole.driver
              ? find.byTooltip(l10n.navAccount)
              : find.text(l10n.navAccount),
        );
        await tester.pump();
        profiles.add(Right(profile.copyWith(role: currentRole)));
        await tester.pumpAndSettle();
        expect(find.byType(AccountScreen), findsOneWidget);
      }

      await openAccount(role);
      final switchLabel = role == UserRole.rider
          ? l10n.accountDrive
          : l10n.accountRide;
      await tester.scrollUntilVisible(find.text(switchLabel), 200);
      await tester.tap(find.text(switchLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.accountConfirm));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        nextRole == UserRole.driver ? '/driver' : '/rider',
      );
      if (nextRole == UserRole.rider) verify(presence.close).called(1);
      await openAccount(nextRole);
      await tester.scrollUntilVisible(find.text(l10n.signOutLabel), 200);
      await tester.tap(find.text(l10n.signOutLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.accountConfirm));
      await tester.pumpAndSettle();
      expect(find.text(l10n.phoneTitle), findsOneWidget);
      verify(() => users.setRole('u', role)).called(1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}
