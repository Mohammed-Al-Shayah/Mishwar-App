import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/home/presentation/driver_home_screen.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mocktail/mocktail.dart';
import '../../features/driver/presence/driver_home_screen_test.dart'
    show MockPresenceBloc, map, size, wrap;
import '../../features/driver/presence/driver_presence_bloc_test.dart'
    show driver;

class MockSession extends MockCubit<SessionState> implements SessionCubit {}

void main() {
  setUpAll(() => registerFallbackValue(const GoOnlinePressed()));
  testWidgets('approved driver lands on new dark driver home', (tester) async {
    size(tester);
    final session = MockSession();
    final bloc = MockPresenceBloc();
    whenListen(
      session,
      const Stream<SessionState>.empty(),
      initialState: SessionReady(
        UserEntity(
          id: 'd',
          name: 'Driver',
          phone: '+962791234567',
          createdAt: DateTime.utc(2026),
          role: UserRole.driver,
        ),
        driver: driver(),
      ),
    );
    whenListen(
      bloc,
      const Stream<DriverPresenceState>.empty(),
      initialState: const DriverPresenceState(),
    );
    getIt.registerFactory<DriverPresenceBloc>(() => bloc);
    addTearDown(() => getIt.unregister<DriverPresenceBloc>());
    final refresh = SessionRouterRefresh(session.stream);
    addTearDown(refresh.dispose);
    final router = createAppRouter(session, refresh, driverMapBuilder: map);
    addTearDown(router.dispose);
    // The shared wrapper provides localization and ScreenUtil to the router.
    await tester.pumpWidget(
      wrap(
        Router(
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/driver');
    expect(find.byType(DriverHomeScreen), findsOneWidget);
    verify(() => bloc.add(any(that: isA<Started>()))).called(1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
