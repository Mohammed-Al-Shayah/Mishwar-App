import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/admin/presentation/admin_content_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';
import 'package:mishwar/features/admin/presentation/admin_login_screen.dart';
import 'package:mishwar/features/admin/presentation/admin_screen.dart';
import 'package:mishwar/features/admin/presentation/management_cubit.dart';
import 'package:mishwar/features/admin/presentation/reports_cubit.dart';
import 'package:mishwar/features/common/account/presentation/account_cubit.dart';
import 'package:mishwar/features/common/account/presentation/account_screen.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/name_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/role_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/name_screen.dart';
import 'package:mishwar/features/common/auth/presentation/screens/otp_screen.dart';
import 'package:mishwar/features/common/auth/presentation/screens/phone_screen.dart';
import 'package:mishwar/features/common/auth/presentation/screens/role_screen.dart';
import 'package:mishwar/features/common/auth/presentation/screens/splash_screen.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_cubit.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/common/safety/presentation/safety_screen.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_cubit.dart';
import 'package:mishwar/features/common/safety/presentation/trusted_contacts_cubit.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mishwar/features/common/support/presentation/support_screens.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_screen.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/home/presentation/driver_shell.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_onboarding_screen.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_pending_screen.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/driver/rating/presentation/driver_rating_screen.dart';
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart'
    as trip;
import 'package:mishwar/features/driver/trip/presentation/driver_trip_screen.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_cubit.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_screen.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_screen.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/rider_home_screen.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/services_grid.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_cubit.dart';
import 'package:mishwar/features/rider/parcel/presentation/parcel_form_screen.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_cubit.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_screen.dart';
import 'package:mishwar/features/rider/places/presentation/saved_places_screen.dart';
import 'package:mishwar/features/rider/ride/presentation/active_ride_listener.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_summary_screen.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_tracking_screen.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/destination_search_screen.dart';

String? sessionRedirect(
  SessionState session,
  String location, {
  Object? extra,
  bool isWeb = kIsWeb,
}) {
  if (isWeb) {
    final target = switch (session) {
      SessionUnknown() || SessionError() => '/splash',
      SessionWeb(:final authUser) =>
        authUser.isAdmin
            ? (location == '/admin' ||
                      location.startsWith('/admin/') &&
                          ![
                            '/admin/sign-in',
                            '/admin/denied',
                          ].contains(location)
                  ? location
                  : '/admin')
            : '/admin/denied',
      _ => '/admin/sign-in',
    };
    return location == target ? null : target;
  }
  final target = switch (session) {
    SessionWeb() => '/auth/phone',
    SessionUnknown() || SessionError() => '/splash',
    SessionSignedOut() =>
      location == '/auth/otp' && extra is OtpSession
          ? '/auth/otp'
          : '/auth/phone',
    SessionNeedsName() => '/auth/name',
    SessionNeedsRole() => '/role',
    SessionReady(:final user, :final driver) =>
      user.role == UserRole.rider &&
              (location == '/rider' || location.startsWith('/rider/history')) &&
              user.pendingRatingRideId != null
          ? '/rider/ride/${user.pendingRatingRideId}/summary'
          : user.role != UserRole.driver
          ? (user.role == UserRole.rider &&
                    ((location == '/rider/account' ||
                            location == '/rider/support' ||
                            location.startsWith('/rider/support/') ||
                            location == '/rider/safety' ||
                            location == '/rider/places' ||
                            location == '/rider/services' ||
                            location == '/rider/parcel' ||
                            location == '/rider/airport' ||
                            location == '/rider/history' ||
                            RegExp(
                              r'^/rider/history/[^/]+$',
                            ).hasMatch(location)) ||
                        (location == '/rider/search' &&
                            extra is DestinationSearchParams) ||
                        (location == '/rider/confirm' && extra is RideDraft) ||
                        ((location == '/rider/pickup' ||
                                location == '/rider/pin') &&
                            extra is RideStop) ||
                        RegExp(
                          r'^/rider/ride/[^/]+(/summary)?$',
                        ).hasMatch(location))
                ? location
                : '/rider')
          : switch (driver?.status) {
              null => '/driver/onboarding',
              DriverStatus.approved =>
                (location == '/driver' ||
                            location == '/driver/earnings' ||
                            location.startsWith('/driver/history/')) &&
                        driver?.pendingRatingRideId != null
                    ? '/driver/ride/${driver!.pendingRatingRideId}/rate'
                    : (location == '/driver' ||
                              location == '/driver/earnings' ||
                              location.startsWith('/driver/history/')) &&
                          driver?.currentRideId != null
                    ? '/driver/ride/${driver!.currentRideId}'
                    : (location == '/driver/account' ||
                          location == '/driver/support' ||
                          location.startsWith('/driver/support/') ||
                          location == '/driver/safety' ||
                          location == '/driver/earnings' ||
                          RegExp(
                            r'^/driver/history/[^/]+$',
                          ).hasMatch(location) ||
                          RegExp(
                            r'^/driver/ride/[^/]+(/rate)?$',
                          ).hasMatch(location))
                    ? location
                    : '/driver',
              DriverStatus.rejected when location == '/driver/onboarding' =>
                '/driver/onboarding',
              _ => '/driver/pending',
            },
  };
  return location == target ? null : target;
}

class SessionRouterRefresh extends ChangeNotifier {
  SessionRouterRefresh(Stream<SessionState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<SessionState> _subscription;
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

GoRouter createAppRouter(
  SessionCubit session,
  SessionRouterRefresh refresh, {
  WidgetBuilder? riderMapBuilder,
  WidgetBuilder? driverMapBuilder,
  WidgetBuilder? pickupMapBuilder,
}) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (_, state) =>
      sessionRedirect(session.state, state.uri.path, extra: state.extra),
  routes: [
    GoRoute(
      path: '/admin/sign-in',
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<AdminLoginCubit>(),
        child: const AdminLoginScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/denied',
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<AdminLoginCubit>(),
        child: const AdminLoginScreen(denied: true),
      ),
    ),
    for (final section in AdminSection.values)
      GoRoute(
        path: section == AdminSection.overview
            ? '/admin'
            : '/admin/${section.name}',
        builder: (_, routeState) => MultiBlocProvider(
          key: ValueKey(routeState.uri.toString()),
          providers: [
            BlocProvider(create: (_) => getIt<AdminLoginCubit>()),
            if (section == AdminSection.support) ...[
              BlocProvider(create: (_) => _supportList()),
              BlocProvider(
                create: (_) {
                  final cubit = getIt<SupportThreadCubit>();
                  final id = routeState.uri.queryParameters['ticket'];
                  if (id != null) unawaited(cubit.start(id, admin: true));
                  return cubit;
                },
              ),
            ],
            if ([AdminSection.settings, AdminSection.promos].contains(section))
              BlocProvider(
                create: (_) {
                  final cubit = getIt<ManagementCubit>();
                  unawaited(cubit.load());
                  return cubit;
                },
              ),
            if (section == AdminSection.reports)
              BlocProvider(
                create: (_) {
                  final cubit = getIt<ReportsCubit>();
                  unawaited(cubit.load());
                  return cubit;
                },
              ),
            if (section == AdminSection.content)
              BlocProvider(create: (_) => getIt<AdminContentCubit>()..start()),
            BlocProvider(
              create: (_) {
                final cubit = getIt<AdminCubit>();
                unawaited(
                  cubit.start(
                    section,
                    rideId: routeState.uri.queryParameters['rideId'],
                  ),
                );
                return cubit;
              },
            ),
          ],
          child: AdminScreen(
            supportTicketId: routeState.uri.queryParameters['ticket'],
          ),
        ),
      ),
    _supportRoute('rider', session),
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/auth/phone',
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<PhoneCubit>(),
        child: const PhoneScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/otp',
      builder: (_, state) => BlocProvider(
        create: (_) => getIt<OtpCubit>(param1: state.extra! as OtpSession),
        child: const OtpScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/name',
      builder: (_, _) {
        final state = session.state;
        if (state is! SessionNeedsName) return const SplashScreen();
        return BlocProvider(
          create: (_) => getIt<NameCubit>(),
          child: NameScreen(user: state.authUser),
        );
      },
    ),
    GoRoute(
      path: '/role',
      builder: (_, _) {
        final state = session.state;
        if (state is! SessionNeedsRole) return const SplashScreen();
        return BlocProvider(
          create: (_) => getIt<RoleCubit>(),
          child: RoleScreen(user: state.user),
        );
      },
    ),
    GoRoute(
      path: '/rider',
      routes: [
        GoRoute(
          path: 'safety',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<TrustedContactsCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: const SafetyScreen(),
          ),
        ),
        GoRoute(
          path: 'airport',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<AirportCubit>();
              unawaited(cubit.load());
              return cubit;
            },
            child: AirportScreen(
              pickupAvailable:
                  pickupMapBuilder != null || riderMapBuilder == null,
            ),
          ),
        ),
        GoRoute(
          path: 'parcel',
          builder: (_, _) => BlocProvider(
            create: (_) => getIt<ParcelFormCubit>(),
            child: ParcelFormScreen(
              uid: (session.state as SessionReady).user.id,
              pickupAvailable:
                  pickupMapBuilder != null || riderMapBuilder == null,
            ),
          ),
        ),
        GoRoute(
          path: 'services',
          builder: (_, _) => BlocProvider.value(
            value: getIt<AppConfigCubit>(),
            child: const ServicesScreen(),
          ),
        ),
        GoRoute(
          path: 'account',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<AccountCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: BlocProvider(
              create: (_) =>
                  _supportList(uid: (session.state as SessionReady).user.id),
              child: BlocBuilder<SupportListCubit, SupportListState>(
                builder: (_, state) =>
                    AccountScreen(supportUnread: state.unread),
              ),
            ),
          ),
        ),
        GoRoute(
          path: 'history',
          routes: [
            GoRoute(
              path: ':rideId',
              builder: (_, state) => BlocProvider(
                create: (_) {
                  final cubit = getIt<RideReceiptCubit>();
                  unawaited(cubit.load(state.pathParameters['rideId']!));
                  return cubit;
                },
                child: RideReceiptScreen(
                  rideId: state.pathParameters['rideId']!,
                ),
              ),
            ),
          ],
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<HomeCubit>()),
              BlocProvider(
                create: (_) {
                  final cubit = getIt<RideHistoryCubit>();
                  unawaited(
                    cubit.loadFirst((session.state as SessionReady).user.id),
                  );
                  return cubit;
                },
              ),
            ],
            child: ActiveRideListener(
              watch: getIt<WatchActiveRideId>(),
              uid: (session.state as SessionReady).user.id,
              child: const RideHistoryScreen(),
            ),
          ),
        ),
        GoRoute(
          path: 'ride/:rideId',
          routes: [
            GoRoute(
              path: 'summary',
              builder: (_, state) => BlocProvider(
                create: (_) => getIt<RideTrackingBloc>(
                  param1: state.pathParameters['rideId'],
                ),
                child: BlocProvider(
                  create: (_) => getIt<RatingCubit>(
                    param1: state.pathParameters['rideId'],
                    param2: RatingSide.rider,
                  ),
                  child: const RideSummaryScreen(),
                ),
              ),
            ),
          ],
          builder: (_, state) => BlocProvider(
            create: (_) =>
                getIt<RideTrackingBloc>(param1: state.pathParameters['rideId']),
            child: _tripSafetyScope(
              session,
              RideTrackingScreen(mapBuilder: riderMapBuilder),
            ),
          ),
        ),
        GoRoute(
          path: 'search',
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<DestinationSearchBloc>(
                  param1: state.extra! as DestinationSearchParams,
                ),
              ),
              BlocProvider(
                create: (_) {
                  final cubit = getIt<SavedPlacesCubit>();
                  unawaited(
                    cubit.start((session.state as SessionReady).user.id),
                  );
                  return cubit;
                },
              ),
            ],
            child: DestinationSearchScreen(
              pickupName: (state.extra! as DestinationSearchParams).pickupName,
            ),
          ),
        ),
        GoRoute(
          path: 'places',
          builder: (_, state) => BlocProvider(
            create: (_) {
              final cubit = getIt<SavedPlacesCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: SavedPlacesScreen(
              openEditorFor: state.extra is SavedPlaceLabel
                  ? state.extra! as SavedPlaceLabel
                  : null,
            ),
          ),
        ),
        GoRoute(
          path: 'pickup',
          builder: (_, state) => BlocProvider(
            create: (_) =>
                getIt<PickupConfirmCubit>(param1: state.extra! as RideStop),
            child: PickupConfirmScreen(
              mapBuilder: pickupMapBuilder ?? riderMapBuilder,
            ),
          ),
        ),
        GoRoute(
          path: 'pin',
          builder: (_, state) => BlocProvider(
            create: (_) =>
                getIt<PickupConfirmCubit>(param1: state.extra! as RideStop),
            child: PickupConfirmScreen(
              mapBuilder: pickupMapBuilder ?? riderMapBuilder,
              forDestination: true,
            ),
          ),
        ),
        GoRoute(
          path: 'confirm',
          builder: (_, state) => BlocProvider(
            create: (_) =>
                getIt<RideConfirmCubit>(param1: state.extra! as RideDraft),
            child: RideConfirmScreen(
              draft: state.extra! as RideDraft,
              mapBuilder: riderMapBuilder,
              pickupAvailable:
                  pickupMapBuilder != null || riderMapBuilder == null,
            ),
          ),
        ),
      ],
      builder: (_, state) => BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<AppConfigCubit>()),
            BlocProvider(create: (_) => getIt<RiderHomeCubit>()),
            BlocProvider(
              create: (_) {
                final cubit = getIt<SavedPlacesCubit>();
                unawaited(cubit.start((session.state as SessionReady).user.id));
                return cubit;
              },
            ),
            BlocProvider(
              create: (_) {
                final cubit = getIt<RecentPlacesCubit>();
                unawaited(cubit.load((session.state as SessionReady).user.id));
                return cubit;
              },
            ),
          ],
          child: ActiveRideListener(
            watch: getIt<WatchActiveRideId>(),
            uid: (session.state as SessionReady).user.id,
            child: RiderHomeScreen(
              mapBuilder: riderMapBuilder,
              pickupAvailable:
                  pickupMapBuilder != null || riderMapBuilder == null,
              initialService: state.extra is ServiceId
                  ? state.extra! as ServiceId
                  : null,
            ),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/driver/onboarding',
      builder: (_, _) {
        final state = session.state;
        if (state is! SessionReady) return const SplashScreen();
        return BlocProvider(
          create: (_) => getIt<DriverOnboardingCubit>(),
          child: DriverOnboardingScreen(
            uid: state.user.id,
            driver: state.driver,
          ),
        );
      },
    ),
    GoRoute(
      path: '/driver/pending',
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: const DriverPendingScreen(),
      ),
    ),
    ShellRoute(
      builder: (_, _, child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) =>
                getIt<offer.DriverOfferBloc>()
                  ..add(offer.Started((session.state as SessionReady).user.id)),
          ),
          BlocProvider(create: (_) => getIt<DriverPresenceBloc>()),
        ],
        child: DriverShell(
          uid: (session.state as SessionReady).user.id,
          child: child,
        ),
      ),
      routes: [
        _supportRoute('driver', session),
        GoRoute(
          path: '/driver/safety',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<TrustedContactsCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: const SafetyScreen(driver: true),
          ),
        ),
        GoRoute(
          path: '/driver/account',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<AccountCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: BlocProvider(
              create: (_) =>
                  _supportList(uid: (session.state as SessionReady).user.id),
              child: BlocBuilder<SupportListCubit, SupportListState>(
                builder: (_, state) =>
                    AccountScreen(driver: true, supportUnread: state.unread),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/driver',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<DriverEarningsCubit>();
              unawaited(cubit.start((session.state as SessionReady).user.id));
              return cubit;
            },
            child: DriverHomeScreen(
              uid: (session.state as SessionReady).user.id,
              mapBuilder: driverMapBuilder,
            ),
          ),
        ),
        GoRoute(
          path: '/driver/earnings',
          builder: (_, _) => BlocProvider(
            create: (_) {
              final cubit = getIt<EarningsScreenCubit>();
              unawaited(cubit.load((session.state as SessionReady).user.id));
              return cubit;
            },
            child: DriverEarningsScreen(
              uid: (session.state as SessionReady).user.id,
            ),
          ),
        ),
        GoRoute(
          path: '/driver/history/:rideId',
          builder: (_, state) => BlocProvider(
            create: (_) {
              final cubit = getIt<RideReceiptCubit>();
              unawaited(cubit.load(state.pathParameters['rideId']!));
              return cubit;
            },
            child: RideReceiptScreen(
              rideId: state.pathParameters['rideId']!,
              driver: true,
            ),
          ),
        ),
        GoRoute(
          path: '/driver/ride/:rideId',
          routes: [
            GoRoute(
              path: 'rate',
              builder: (_, state) => BlocProvider(
                create: (_) => getIt<RatingCubit>(
                  param1: state.pathParameters['rideId'],
                  param2: RatingSide.driver,
                ),
                child: DriverRatingScreen(
                  rideId: state.pathParameters['rideId']!,
                  watchRide: getIt<WatchRide>(),
                ),
              ),
            ),
          ],
          builder: (_, state) => BlocProvider(
            create: (_) => getIt<trip.DriverTripBloc>(
              param1: state.pathParameters['rideId'],
            ),
            child: _tripSafetyScope(
              session,
              DriverTripScreen(mapBuilder: driverMapBuilder),
            ),
          ),
        ),
      ],
    ),
  ],
);

Widget _tripSafetyScope(SessionCubit session, Widget child) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<TrustedContactsCubit>();
            unawaited(cubit.start((session.state as SessionReady).user.id));
            return cubit;
          },
        ),
        BlocProvider(create: (_) => getIt<TripSafetyCubit>()),
      ],
      child: child,
    );

GoRoute _supportRoute(String mode, SessionCubit session) => GoRoute(
  path: '/$mode/support',
  builder: (_, _) => BlocProvider(
    create: (_) => _supportList(uid: (session.state as SessionReady).user.id),
    child: SupportListScreen(
      uid: (session.state as SessionReady).user.id,
      driver: mode == 'driver',
    ),
  ),
  routes: [
    GoRoute(
      path: 'new',
      builder: (_, state) => BlocProvider(
        create: (_) =>
            getIt<NewSupportCubit>()
              ..start(state.uri.queryParameters['rideId']),
        child: NewSupportScreen(driver: mode == 'driver'),
      ),
    ),
    GoRoute(
      path: ':id',
      builder: (_, state) => BlocProvider(
        create: (_) => _supportThread(state.pathParameters['id']!),
        child: SupportThreadScreen(driver: mode == 'driver'),
      ),
    ),
  ],
);

SupportListCubit _supportList({String? uid}) {
  final cubit = getIt<SupportListCubit>();
  unawaited(cubit.start(uid: uid));
  return cubit;
}

SupportThreadCubit _supportThread(String id) {
  final cubit = getIt<SupportThreadCubit>();
  unawaited(cubit.start(id));
  return cubit;
}
