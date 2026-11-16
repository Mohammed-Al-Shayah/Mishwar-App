import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/app/router/push_router_binding.dart';
import 'package:mishwar/core/l10n/gen/app_localizations.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/watch_push_routes.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

class MishwarApp extends StatefulWidget {
  const MishwarApp({
    this.router,
    this.sessionCubit,
    this.watchPushRoutes,
    this.initialPushRoute,
    super.key,
  });
  final WatchPushRoutes? watchPushRoutes;
  final GetInitialPushRoute? initialPushRoute;
  final GoRouter? router;
  final SessionCubit? sessionCubit;
  @override
  State<MishwarApp> createState() => _MishwarAppState();
}

class _MishwarAppState extends State<MishwarApp> {
  late final SessionCubit _session =
      widget.sessionCubit ?? getIt<SessionCubit>();
  late final SessionRouterRefresh _refresh = SessionRouterRefresh(
    _session.stream,
  );
  late final GoRouter _router =
      widget.router ?? createAppRouter(_session, _refresh);
  PushRouterBinding? _pushBinding;
  @override
  void initState() {
    super.initState();
    final watch = widget.watchPushRoutes;
    final initial = widget.initialPushRoute;
    if (watch != null && initial != null) {
      _pushBinding = PushRouterBinding(_router, watch, initial);
    }
  }

  @override
  void dispose() {
    _pushBinding?.dispose();
    if (widget.router == null) _router.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _session,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => BlocBuilder<SessionCubit, SessionState>(
        builder: (context, session) => MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode:
              session is SessionReady && session.user.role == UserRole.driver
              ? ThemeMode.dark
              : ThemeMode.system,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          onGenerateTitle: (context) => context.l10n.appName,
        ),
      ),
    ),
  );
}
