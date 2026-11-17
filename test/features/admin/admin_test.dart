import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/domain/admin_usecases.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_login_screen.dart';
import 'package:mishwar/features/admin/presentation/admin_screen.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/pricing/domain/entities/pricing_table.dart';
import 'package:mishwar/features/common/pricing/domain/fare_calculator.dart';
import 'package:mocktail/mocktail.dart';

class MockSignOut extends Mock implements SignOut {}

class TestAdminRepository implements AdminRepository {
  final queries = <AdminQuery>[];
  final actions = <(String, Map<String, Object>)>[];
  final feed = StreamController<Either<Failure, AdminData>>.broadcast();
  bool fail = false;
  AdminData data = AdminData();
  @override
  Future<Either<Failure, AdminData>> load(AdminQuery query) async {
    queries.add(query);
    return fail ? const Left(ServerFailure('offline')) : Right(data);
  }

  @override
  Stream<Either<Failure, AdminData>> watch(AdminSection section) => feed.stream;
  @override
  Future<Either<Failure, String>> license(String path) async => fail
      ? const Left(ServerFailure('license'))
      : const Right('https://example.test/license');
  @override
  Future<Either<Failure, Unit>> action(
    String name,
    Map<String, Object> arguments,
  ) async {
    actions.add((name, arguments));
    return fail ? const Left(ServerFailure('action')) : const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signIn(String email, String password) async =>
      fail ? const Left(ServerFailure('sign-in')) : const Right(unit);
}

AdminCubit makeCubit(TestAdminRepository repository) => AdminCubit(
  WatchAdminData(repository),
  LoadAdminPage(repository),
  AdminAction(repository),
  LoadAdminLicense(repository),
  const FareCalculator(),
);

void main() {
  test('admin guard: web claim, no claim, signed out, mobile, all pages', () {
    const admin = SessionWeb(AuthUser(uid: 'a', isAdmin: true));
    const regular = SessionWeb(AuthUser(uid: 'r'));
    for (final path in [
      '/admin',
      '/admin/drivers',
      '/admin/rides',
      '/admin/map',
      '/admin/pricing',
    ]) {
      expect(sessionRedirect(admin, path, isWeb: true), isNull);
      expect(sessionRedirect(regular, path, isWeb: true), '/admin/denied');
      expect(
        sessionRedirect(const SessionSignedOut(), path, isWeb: true),
        '/admin/sign-in',
      );
      expect(sessionRedirect(admin, path, isWeb: false), '/auth/phone');
      expect(
        sessionRedirect(const SessionSignedOut(), path, isWeb: false),
        '/auth/phone',
      );
    }
    expect(sessionRedirect(admin, '/admin/sign-in', isWeb: true), '/admin');
    expect(sessionRedirect(regular, '/admin/denied', isWeb: true), isNull);
    expect(
      sessionRedirect(const SessionSignedOut(), '/admin/sign-in', isWeb: true),
      isNull,
    );
  });

  test(
    'drivers filter/search, cursor pages and reset; rides date range',
    () async {
      final repo = TestAdminRepository();
      final cubit = makeCubit(repo);
      repo.data = AdminData(
        entries: [
          AdminEntry(
            id: 'a',
            status: 'pending',
            name: 'Ahmad',
            phone: '+962123',
            plate: 'ABC',
          ),
        ],
        next: 'a',
      );
      await cubit.start(AdminSection.drivers);
      expect(repo.queries.last.status, 'pending');
      for (final term in ['ahmad', '962', 'abc']) {
        cubit.search(term);
        expect(cubit.state.entries, hasLength(1));
      }
      cubit.search('missing');
      expect(cubit.state.entries, isEmpty);
      await cubit.next();
      expect(repo.queries.last.after, 'a');
      expect(cubit.state.page, 1);
      await cubit.previous();
      expect(repo.queries.last.after, isNull);
      await cubit.next();
      await cubit.filter(status: 'approved');
      expect(repo.queries.last.status, 'approved');
      expect(repo.queries.last.after, isNull);
      expect(cubit.state.page, 0);
      await cubit.start(AdminSection.rides);
      final from = DateTime(2026);
      final to = DateTime(2026, 1, 8);
      await cubit.filter(status: 'completed', from: from, to: to);
      expect(repo.queries.last.from, from);
      expect(repo.queries.last.to, to);
      repo.fail = true;
      await cubit.reload();
      expect(cubit.state.failure, isA<ServerFailure>());
      expect(cubit.state.loading, isFalse);
      await cubit.close();
      await repo.feed.close();
    },
  );

  for (final section in [
    AdminSection.overview,
    AdminSection.map,
    AdminSection.pricing,
  ]) {
    blocTest<AdminCubit, AdminState>(
      '${section.name} streams data and failure',
      build: () {
        final repo = TestAdminRepository();
        addTearDown(repo.feed.close);
        return makeCubit(repo);
      },
      act: (cubit) async {
        await cubit.start(section);
      },
      verify: (cubit) {
        expect(cubit.state.section, section);
      },
    );
    test('${section.name} stream updates and errors', () async {
      final repo = TestAdminRepository();
      final cubit = makeCubit(repo);
      await cubit.start(section);
      repo.feed.add(Right(AdminData(stats: const [2, 3, 4, 5])));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data!.stats, [2, 3, 4, 5]);
      repo.feed.add(const Left(ServerFailure('stream')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.failure, isA<ServerFailure>());
      await cubit.close();
      await repo.feed.close();
    });
  }
  test(
    'admin actions, failures, license and pricing validation/preview',
    () async {
      final repo = TestAdminRepository();
      final cubit = makeCubit(repo);
      await cubit.start(AdminSection.drivers);
      for (final name in ['reviewDriver', 'adminCancelRide', 'updatePricing']) {
        expect(await cubit.act(name, {'reason': 'review'}), isTrue);
        expect(repo.actions.last.$1, name);
      }
      await cubit.showLicense('drivers/a/license');
      expect(cubit.state.licenseUrl, isNotNull);
      await cubit.showLicense(null);
      expect(cubit.state.licenseUrl, isNull);
      repo.fail = true;
      expect(await cubit.act('reviewDriver', {}), isFalse);
      expect(cubit.state.busy, isFalse);
      await cubit.showLicense('drivers/a/license');
      // A missing photo shows the no-photo note, not a page error.
      expect(cubit.state.licenseUrl, isEmpty);
      for (final text in [
        '0',
        '-1',
        '50.001',
        'NaN',
        'Infinity',
        'x',
        '0.0001',
      ]) {
        expect(AdminCubit.parseRate(text), isNull);
      }
      expect(AdminCubit.parseRate('50'), 50000);
      expect(AdminCubit.parseRate('0.001'), 1);
      expect(
        cubit.preview(PricingTable.defaults().rates.values.first).toJodString(),
        '4.50',
      );
      await cubit.close();
      await repo.feed.close();
    },
  );
  blocTest<AdminLoginCubit, AdminLoginState>(
    'email login failure is shown',
    build: () => AdminLoginCubit(
      AdminSignIn(TestAdminRepository()..fail = true),
      MockSignOut(),
    ),
    act: (cubit) => cubit.signIn('admin@example.test', 'password'),
    expect: () => [
      const AdminLoginState(loading: true),
      const AdminLoginState(failed: true),
    ],
  );

  for (final locale in ['ar', 'en']) {
    for (final section in AdminSection.values) {
      testWidgets('${section.name} at 1280x800 in $locale', (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = TestAdminRepository();
        final entry = AdminEntry(
          id: 'a',
          status: section == AdminSection.drivers ? 'pending' : 'accepted',
          name: 'Ahmad',
          phone: '+962123',
          plate: 'ABC',
          vehicle: 'Toyota',
          rider: 'Rider A',
          driver: 'Driver A',
          pickup: 'Amman',
          dropoff: 'Irbid',
          estimated: 4500,
          lat: 31.9,
          lng: 35.9,
          createdAt: DateTime(2026),
        );
        repo.data = AdminData(
          entries: [entry],
          stats: const [1, 2, 3, 4],
          pricing: PricingTable.defaults(),
        );
        final cubit = makeCubit(repo);
        await cubit.start(section);
        if (![AdminSection.drivers, AdminSection.rides].contains(section)) {
          repo.feed.add(Right(repo.data));
          await tester.pump();
        }

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            enableScaleWH: () => false,
            enableScaleText: () => false,
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: cubit),
                BlocProvider(
                  create: (_) =>
                      AdminLoginCubit(AdminSignIn(repo), MockSignOut()),
                ),
              ],
              child: MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const AdminScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(AdminScreen));
        final l10n = AppLocalizations.of(context)!;
        if (section == AdminSection.map) {
          expect(find.text(l10n.adminMapFallback), findsOneWidget);
          expect(find.textContaining('31.9'), findsOneWidget);
        }
        if (section == AdminSection.pricing) {
          expect(find.textContaining('4.50'), findsOneWidget);
          await tester.enterText(find.byKey(const ValueKey('economy-0')), '0');
          await tester.tap(find.text(l10n.adminSave));
          await tester.pumpAndSettle();
          expect(find.text(l10n.adminRateInvalid), findsWidgets);
          expect(repo.actions, isEmpty);
          await tester.enterText(find.byKey(const ValueKey('economy-0')), '1');
          await tester.pumpAndSettle();
          expect(find.textContaining('5.00'), findsOneWidget);
          await tester.tap(find.text(l10n.adminSave));
          await tester.pumpAndSettle();
          expect(repo.actions.single.$1, 'updatePricing');
          expect(
            (repo.actions.single.$2['economy']! as Map<String, Object>)['base'],
            1,
          );
        }
        if (section == AdminSection.drivers) {
          await tester.tap(find.text('Ahmad'));
          await tester.pumpAndSettle();
          expect(find.text(l10n.adminApprove), findsOneWidget);
          expect(find.text(l10n.adminReject), findsOneWidget);
          await tester.tap(find.text(l10n.adminReject));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.adminConfirm));
          await tester.pumpAndSettle();
          expect(repo.actions, isEmpty);
          await tester.enterText(find.byType(TextFormField), 'documents');
          await tester.tap(find.text(l10n.adminConfirm));
          await tester.pumpAndSettle();
          expect(repo.actions.single.$2['decision'], 'reject');
          expect(repo.actions.single.$2['reason'], 'documents');
        }
        if (section == AdminSection.rides) {
          await tester.tap(find.text('Rider A'));
          await tester.pumpAndSettle();
          expect(find.text(l10n.adminTimeline), findsOneWidget);
          await tester.tap(find.text(l10n.adminCancelRide));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextFormField), 'support');
          await tester.tap(find.text(l10n.adminConfirm));
          await tester.pumpAndSettle();
          expect(repo.actions.single.$1, 'adminCancelRide');
          expect(repo.actions.single.$2['reason'], 'support');
        }

        await tester.pumpWidget(const SizedBox.shrink());

        unawaited(cubit.close());
        await tester.pumpAndSettle();
        await repo.feed.close();
      });
    }
    testWidgets(
      'denied login shows localized message and sign out in $locale',
      (tester) async {
        final repo = TestAdminRepository();
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            enableScaleWH: () => false,
            enableScaleText: () => false,
            builder: (_, _) => BlocProvider(
              create: (_) => AdminLoginCubit(AdminSignIn(repo), MockSignOut()),
              child: MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const AdminLoginScreen(denied: true),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsNothing);
        expect(tester.takeException(), isNull);
        await repo.feed.close();
      },
    );
  }
  testWidgets('small screens show larger screen notice', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AdminScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Open on a larger screen'), findsOneWidget);
  });
}
