import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/core/settings/locale_cubit.dart';
import 'package:mishwar/core/settings/theme_mode_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/saved_places_mocks.dart' show appConfigCubit;

class MockSession extends Mock implements SessionCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'locale defaults to Arabic, persists English, ignores unsupported values',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);
      expect(cubit.state, const Locale('ar'));
      await cubit.setLocale('en');
      final restored = LocaleCubit(prefs);
      expect(restored.state, const Locale('en'));
      await restored.close();
      await cubit.setLocale('fr');
      expect(cubit.state, const Locale('en'));
      await cubit.setLocale('ar');
      expect(prefs.getString('locale'), 'ar');
      await cubit.close();
    },
  );
  test('theme defaults to system and persists all modes', () async {
    final prefs = await SharedPreferences.getInstance();
    final cubit = ThemeModeCubit(prefs);
    expect(cubit.state, ThemeMode.system);
    for (final mode in ThemeMode.values) {
      await cubit.setMode(mode);
      final restored = ThemeModeCubit(prefs);
      expect(restored.state, mode);
      await restored.close();
    }
    await cubit.close();
  });
  for (final role in UserRole.values) {
    testWidgets('app switches direction and theme for ${role.name}', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final locale = LocaleCubit(prefs);
      final theme = ThemeModeCubit(prefs);
      final session = MockSession();
      when(() => session.state).thenReturn(
        SessionReady(
          UserEntity(
            id: 'u',
            name: 'Test',
            phone: '+962790000000',
            role: role,
            createdAt: DateTime.utc(2026),
          ),
        ),
      );
      when(() => session.stream).thenAnswer((_) => const Stream.empty());
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('content')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MishwarApp(
          appConfigCubit: appConfigCubit(),
          router: router,
          sessionCubit: session,
          localeCubit: locale,
          themeModeCubit: theme,
        ),
      );
      await tester.pumpAndSettle();
      BuildContext content() => tester.element(find.text('content'));
      expect(Directionality.of(content()), TextDirection.rtl);
      await locale.setLocale('en');
      await theme.setMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(Directionality.of(content()), TextDirection.ltr);
      expect(
        Theme.of(content()).brightness,
        role == UserRole.driver ? Brightness.dark : Brightness.light,
      );
      await locale.setLocale('ar');
      await theme.setMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(Directionality.of(content()), TextDirection.rtl);
      expect(Theme.of(content()).brightness, Brightness.dark);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
