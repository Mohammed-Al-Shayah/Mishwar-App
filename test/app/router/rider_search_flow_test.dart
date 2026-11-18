import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/mw_search_pill.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/places/domain/usecases/get_place_details.dart';
import 'package:mishwar/features/common/places/domain/usecases/search_places.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_state.dart';
import 'package:mishwar/features/rider/places/presentation/saved_places_screen.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/destination_search_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/rider/confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, estimates;
import '../../features/rider/search/destination_search_bloc_test.dart'
    show MockPlacesRepository, details, point, suggestion;
import '../../helpers/ride_mocks.dart';
import '../../helpers/saved_places_mocks.dart';

class MockSession extends MockCubit<SessionState> implements SessionCubit {}

class MockHome extends MockCubit<SubmissionState> implements HomeCubit {}

class MockRiderHome extends MockCubit<RiderHomeState>
    implements RiderHomeCubit {}

void main() {
  setUp(registerSavedPlaces);
  testWidgets('home search returns destination and pushes a ride draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await getIt.unregister<SavedPlacesCubit>();
    await getIt.unregister<RecentPlacesCubit>();
    getIt
      ..registerFactory<SavedPlacesCubit>(
        () => savedCubit(places: [savedHome]),
      )
      ..registerFactory<RecentPlacesCubit>(
        () => recentCubit(places: [savedOther.details]),
      );
    final session = MockSession();
    final home = MockHome();
    final rider = MockRiderHome();
    final repository = MockPlacesRepository();
    whenListen(
      session,
      const Stream<SessionState>.empty(),
      initialState: SessionReady(
        UserEntity(
          id: 'u',
          name: 'User',
          phone: '+962791234567',
          createdAt: DateTime.utc(2026),
          role: UserRole.rider,
        ),
      ),
    );
    whenListen(
      home,
      const Stream<SubmissionState>.empty(),
      initialState: const SubmissionState(),
    );
    whenListen(
      rider,
      const Stream<RiderHomeState>.empty(),
      initialState: const RiderHomeState(
        permission: LocationPermissionStatus.granted,
        position: point,
      ),
    );
    when(rider.start).thenAnswer((_) async {});
    when(
      () => repository.search(
        input: 'Park',
        sessionToken: any(named: 'sessionToken'),
        bias: point,
        lang: 'en',
      ),
    ).thenAnswer((_) async => const Right([suggestion]));
    when(
      () => repository.details(
        placeId: 'p',
        sessionToken: any(named: 'sessionToken'),
        lang: 'en',
      ),
    ).thenAnswer((_) async => const Right(details));
    final routes = MockRouteRepository();
    getIt
      ..registerFactoryParam<RideConfirmCubit, RideDraft, dynamic>((
        draft,
        _,
      ) {
        when(
          () => routes.getFareEstimates(
            origin: draft.pickup.location,
            destination: draft.dropoff.location,
          ),
        ).thenAnswer((_) async => Right(estimates));
        return RideConfirmCubit(
          GetFareEstimates(routes),
          requestRideStub(),
          draft,
          validatePromo: promoValidatorStub(),
          scheduleRide: scheduleRideStub(),
        );
      })
      ..registerFactory<HomeCubit>(() => home)
      ..registerFactory<RiderHomeCubit>(() => rider)
      ..registerFactoryParam<
        DestinationSearchBloc,
        DestinationSearchParams,
        dynamic
      >(
        (params, _) => DestinationSearchBloc(
          SearchPlaces(repository),
          GetPlaceDetails(repository),
          params,
        ),
      );
    addTearDown(getIt.reset);
    final refresh = SessionRouterRefresh(session.stream);
    getIt.registerSingleton<WatchActiveRideId>(emptyActiveRideWatch());
    final router = createAppRouter(
      session,
      refresh,
      riderMapBuilder: (_) => const MwMapPlaceholder(),
    );
    addTearDown(refresh.dispose);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/rider/places'));
    await tester.pumpAndSettle();
    expect(find.byType(SavedPlacesScreen), findsOneWidget);
    expect(router.state.uri.path, '/rider/places');
    router.pop();
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/rider/places', extra: SavedPlaceLabel.home));
    await tester.pumpAndSettle();
    expect(find.byType(RadioListTile<SavedPlaceLabel>), findsNWidgets(3));
    router.pop();
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    for (final path in ['/rider/search', '/rider/confirm']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/rider');
      router.go(path, extra: 'invalid');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/rider');
    }
    await tester.tap(find.byType(MwSearchPill));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationSearchScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Park');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text(suggestion.primaryText));
    await tester.pumpAndSettle();
    expect(find.byType(RideConfirmScreen), findsOneWidget);
    final confirm = tester.widget<RideConfirmScreen>(
      find.byType(RideConfirmScreen),
    );
    expect(confirm.draft.pickup.location, point);
    expect(confirm.draft.pickup.name, 'Your current location');
    expect(confirm.draft.dropoff.name, details.name);
    expect(confirm.draft.dropoff.address, details.address);
    expect(confirm.draft.dropoff.location, details.location);
    await tester.tap(find.byType(MwMapFab));
    await tester.pumpAndSettle();
    expect(find.byType(MwSearchPill), findsOneWidget);
    for (final key in ['home_shortcut_home', 'home_recent_park']) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      final direct = tester.widget<RideConfirmScreen>(
        find.byType(RideConfirmScreen),
      );
      expect(direct.draft.pickup.location, point);
      expect(
        direct.draft.dropoff.location,
        key == 'home_shortcut_home' ? savedHome.location : savedOther.location,
      );
      await tester.tap(find.byType(MwMapFab));
      await tester.pumpAndSettle();
    }
  });
}
