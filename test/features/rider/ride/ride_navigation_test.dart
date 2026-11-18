import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mishwar/features/rider/ride/presentation/active_ride_listener.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';
import '../confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, stubSuccess;

Future<void> pumpRouter(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home resumes an active ride emitted after initial render', (
    tester,
  ) async {
    final repository = MockRideRepository();
    final updates = StreamController<Either<Failure, String?>>();
    addTearDown(updates.close);
    when(
      () => repository.watchActiveRideId('rider'),
    ).thenAnswer((_) => updates.stream);
    final router = GoRouter(
      initialLocation: '/rider',
      routes: [
        GoRoute(
          path: '/rider',
          builder: (_, _) => ActiveRideListener(
            watch: WatchActiveRideId(repository),
            uid: 'rider',
            child: const Text('home'),
          ),
        ),
        GoRoute(
          path: '/rider/ride/:id',
          builder: (_, state) => Text(state.pathParameters['id']!),
        ),
      ],
    );
    await pumpRouter(tester, router);
    updates.add(const Right('existing'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/rider/ride/existing',
    );
    expect(find.text('existing'), findsOneWidget);
  });
  for (final result in [
    const Right<Failure, String>('created'),
    const Left<Failure, String>(ActiveRideFailure('existing')),
  ]) {
    testWidgets('confirm navigates using server response $result', (
      tester,
    ) async {
      final routes = MockRouteRepository();
      stubSuccess(routes);
      final router = GoRouter(
        initialLocation: '/rider/confirm',
        routes: [
          GoRoute(
            path: '/rider/confirm',
            builder: (_, _) => BlocProvider(
              create: (_) => RideConfirmCubit(
                GetFareEstimates(routes),
                requestRideStub(result),
                draft,
                scheduleRide: scheduleRideStub(),
              ),
              child: RideConfirmScreen(
                draft: draft,
                mapBuilder: (_) => const MwMapPlaceholder(),
              ),
            ),
          ),
          GoRoute(
            path: '/rider/ride/:id',
            builder: (_, state) => Text(state.pathParameters['id']!),
          ),
        ],
      );
      await pumpRouter(tester, router);
      await tester.tap(find.byType(MwPrimaryButton));
      await tester.pumpAndSettle();
      final expected = result.getRight().getOrElse(() => 'existing');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/rider/ride/$expected',
      );
    });
  }
}
