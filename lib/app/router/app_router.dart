import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/di/injection.dart';
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
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/offer/presentation/driver_ride_placeholder.dart';
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_onboarding_screen.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_pending_screen.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/rider_home_screen.dart';
import 'package:mishwar/features/rider/ride/presentation/active_ride_listener.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/ride_tracking_screen.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/destination_search_screen.dart';

String? sessionRedirect(
  SessionState session,
  String location, {
  Object? extra,
}) {
  final target = switch (session) {
    SessionUnknown() || SessionError() => '/splash',
    SessionSignedOut() =>
      location == '/auth/otp' && extra is OtpSession
          ? '/auth/otp'
          : '/auth/phone',
    SessionNeedsName() => '/auth/name',
    SessionNeedsRole() => '/role',
    SessionReady(:final user, :final driver) =>
      user.role != UserRole.driver
          ? (user.role == UserRole.rider &&
                    ((location == '/rider/search' &&
                            extra is DestinationSearchParams) ||
                        (location == '/rider/confirm' && extra is RideDraft) ||
                        RegExp(r'^/rider/ride/[^/]+$').hasMatch(location))
                ? location
                : '/rider')
          : switch (driver?.status) {
              null => '/driver/onboarding',
              DriverStatus.approved =>
                location == '/driver' && driver?.currentRideId != null
                    ? '/driver/ride/${driver!.currentRideId}'
                    : RegExp(r'^/driver/ride/[^/]+$').hasMatch(location)
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
}) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: refresh,
  redirect: (_, state) =>
      sessionRedirect(session.state, state.uri.path, extra: state.extra),
  routes: [
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
          path: 'ride/:rideId',
          builder: (_, state) => BlocProvider(
            create: (_) =>
                getIt<RideTrackingBloc>(param1: state.pathParameters['rideId']),
            child: RideTrackingScreen(mapBuilder: riderMapBuilder),
          ),
        ),
        GoRoute(
          path: 'search',
          builder: (_, state) => BlocProvider(
            create: (_) => getIt<DestinationSearchBloc>(
              param1: state.extra! as DestinationSearchParams,
            ),
            child: const DestinationSearchScreen(),
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
            ),
          ),
        ),
      ],
      builder: (_, _) => BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: BlocProvider(
          create: (_) => getIt<RiderHomeCubit>(),
          child: ActiveRideListener(
            watch: getIt<WatchActiveRideId>(),
            uid: (session.state as SessionReady).user.id,
            child: RiderHomeScreen(mapBuilder: riderMapBuilder),
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
    GoRoute(
      path: '/driver',
      routes: [
        GoRoute(
          path: 'ride/:rideId',
          builder: (_, state) => DriverRidePlaceholder(
            rideId: state.pathParameters['rideId']!,
            watchRide: getIt<WatchRide>(),
          ),
        ),
      ],
      builder: (_, _) => BlocProvider(
        create: (_) =>
            getIt<offer.DriverOfferBloc>()
              ..add(offer.Started((session.state as SessionReady).user.id)),
        child: BlocProvider(
          create: (_) => getIt<DriverPresenceBloc>(),
          child: DriverHomeScreen(
            uid: (session.state as SessionReady).user.id,
            mapBuilder: driverMapBuilder,
          ),
        ),
      ),
    ),
  ],
);
