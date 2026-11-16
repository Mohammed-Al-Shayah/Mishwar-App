import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/app/router/push_router_binding.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/watch_push_routes.dart';
import 'package:mocktail/mocktail.dart';

class MockPush extends Mock implements PushRepository {}

void main() {
  for (final coldStart in [true, false]) {
    testWidgets(
      'ride offer tap routes to driver, coldStart: $coldStart',
      (tester) async {
        final events = StreamController<String>();
        final push = MockPush();
        when(() => push.openedRoutes).thenAnswer((_) => events.stream);
        when(
          push.initialRoute,
        ).thenAnswer((_) async => Right(coldStart ? '/driver' : null));
        final router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const Text('home')),
            GoRoute(path: '/driver', builder: (_, _) => const Text('driver')),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        final binding = PushRouterBinding(
          router,
          WatchPushRoutes(push),
          GetInitialPushRoute(push),
        );
        if (!coldStart) events.add('/driver');
        await tester.pumpAndSettle();
        expect(find.text('driver'), findsOneWidget);
        binding.dispose();
        unawaited(events.close());
        await tester.pumpWidget(const SizedBox());
        router.dispose();
      },
    );
  }
  testWidgets(
    'other routes and initial failures are ignored, dispose cancels',
    (tester) async {
      final events = StreamController<String>();
      final push = MockPush();
      when(() => push.openedRoutes).thenAnswer((_) => events.stream);
      when(
        push.initialRoute,
      ).thenAnswer((_) async => const Left(ServerFailure('initial')));
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final binding = PushRouterBinding(
        router,
        WatchPushRoutes(push),
        GetInitialPushRoute(push),
      );
      events.add('/admin');
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      binding.dispose();
      unawaited(events.close());
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
}
