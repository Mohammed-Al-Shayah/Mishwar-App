import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_session_binding.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/saved_places_mocks.dart' show appConfigCubit;

class MockSession extends MockCubit<SessionState> implements SessionCubit {}

void main() {
  testWidgets('app watches only after sign-in and stops on sign-out', (
    tester,
  ) async {
    final config = appConfigCubit();
    final session = MockSession();
    final feed = StreamController<SessionState>.broadcast();
    whenListen(session, feed.stream, initialState: const SessionSignedOut());
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: session),
          BlocProvider<AppConfigCubit>.value(value: config),
        ],
        child: const AppConfigSessionBinding(child: SizedBox()),
      ),
    );
    verify(config.stop).called(1);
    verifyNever(() => config.start(any()));
    feed.add(const SessionWeb(AuthUser(uid: 'admin', isAdmin: true)));
    await tester.pump();
    verify(() => config.start('admin')).called(1);
    feed.add(const SessionSignedOut());
    await tester.pump();
    verify(config.stop).called(1);
    await tester.pumpWidget(const SizedBox());
    await feed.close();
  });
}
