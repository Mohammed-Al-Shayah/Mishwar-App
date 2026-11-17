import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/rating/domain/rate_ride.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/domain/skip_rating.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';
import 'package:mishwar/features/common/rating/presentation/rating_exit.dart';
import 'package:mishwar/features/common/rating/presentation/rating_form.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/driver/rating/presentation/driver_rating_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../core/widgets/mw_star_rating_golden_test.dart' show wrap;
import '../../../helpers/rating_mocks.dart';
import '../../../helpers/ride_mocks.dart';
import '../ride/ride_data_test.dart' show rideJson;

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets(
      'rider form positive and negative chips and submission $language',
      (tester) async {
        final repository = MockRideRepository();
        final cubit = RatingCubit(
          RateRide(repository),
          SkipRating(repository),
          'ride',
          RatingSide.rider,
        );
        addTearDown(cubit.close);
        var done = 0;
        when(
          () => repository.rateRide('ride', 2, [RatingTag.dirtyCar], 'note'),
        ).thenAnswer((_) async => const Right(unit));
        await tester.pumpWidget(
          wrap(
            BlocProvider.value(
              value: cubit,
              child: SingleChildScrollView(
                child: RatingForm(name: 'Driver', onDone: () => done++),
              ),
            ),
            language: language,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<MwPrimaryButton>(find.byType(MwPrimaryButton))
              .onPressed,
          isNull,
        );
        expect(find.byType(ChoiceChip), findsNothing);
        await tester.tap(find.byKey(const ValueKey('mw_star_5')));
        await tester.pumpAndSettle();
        expect(
          find.text(language == 'ar' ? 'سيارة نظيفة' : 'Clean car'),
          findsOneWidget,
        );
        expect(
          find.text(language == 'ar' ? 'سيارة مش نظيفة' : 'Dirty car'),
          findsNothing,
        );
        await tester.tap(find.byType(ChoiceChip).at(1));
        await tester.pump();
        expect(cubit.state.tags, [RatingTag.cleanCar]);
        await tester.tap(find.byKey(const ValueKey('mw_star_2')));
        await tester.pumpAndSettle();
        expect(cubit.state.tags, isEmpty);
        expect(
          find.text(language == 'ar' ? 'سيارة نظيفة' : 'Clean car'),
          findsNothing,
        );
        await tester.tap(
          find.text(language == 'ar' ? 'سيارة مش نظيفة' : 'Dirty car'),
        );
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'note');
        await tester.ensureVisible(find.byType(MwPrimaryButton));
        await tester.tap(find.byType(MwPrimaryButton));
        await tester.pumpAndSettle();
        expect(done, 1);
        expect(tester.takeException(), isNull);
      },
    );
    for (final skip in [false, true]) {
      testWidgets(
        'driver dark screen skip=$skip $language',
        (tester) async {
          final repository = MockRideRepository();
          final cubit = RatingCubit(
            RateRide(repository),
            SkipRating(repository),
            'ride',
            RatingSide.driver,
          );
          addTearDown(cubit.close);
          final session = readyRatingSession(role: UserRole.driver);
          addTearDown(session.close);
          final ride = RideModel.fromJson({
            ...rideJson(),
            'status': 'completed',
            'driverId': 'driver',
            'riderInfo': {
              'name': 'Rider',
              'phone': '+962780000001',
              'rating': 5,
            },
          }).toEntity();
          when(
            () => repository.watchRide('ride'),
          ).thenAnswer((_) => Stream.value(Right(ride)));
          when(
            () => repository.skipRating('ride'),
          ).thenAnswer((_) async => const Right(unit));
          when(
            () => repository.rateRide('ride', 5, [], ''),
          ).thenAnswer((_) async => const Right(unit));
          final router = GoRouter(
            initialLocation: '/driver/ride/ride/rate',
            routes: [
              GoRoute(path: '/driver', builder: (_, _) => const Text('home')),
              GoRoute(
                path: '/driver/ride/:id/rate',
                builder: (_, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: cubit),
                    BlocProvider<SessionCubit>.value(value: session),
                  ],
                  child: DriverRatingScreen(
                    rideId: 'ride',
                    watchRide: WatchRide(repository),
                  ),
                ),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            wrap(
              Router(
                routerDelegate: router.routerDelegate,
                routeInformationParser: router.routeInformationParser,
                routeInformationProvider: router.routeInformationProvider,
              ),
              language: language,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(language == 'ar' ? 'قيّم Rider' : 'Rate Rider'),
            findsOneWidget,
          );
          expect(
            Theme.of(tester.element(find.byType(MwStarRating))).brightness,
            Brightness.dark,
          );
          if (skip) {
            await tester.tap(find.text(language == 'ar' ? 'تخطي' : 'Skip'));
          } else {
            await tester.tap(find.byKey(const ValueKey('mw_star_5')));
            await tester.pumpAndSettle();
            expect(find.byType(ChoiceChip), findsNWidgets(5));
            await tester.ensureVisible(find.byType(MwPrimaryButton));
            await tester.tap(find.byType(MwPrimaryButton));
          }
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/driver');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('success waits for session pending pointer to clear', (
    tester,
  ) async {
    final repository = MockRideRepository();
    final cubit = RatingCubit(
      RateRide(repository),
      SkipRating(repository),
      'ride',
      RatingSide.rider,
    );
    addTearDown(cubit.close);
    final session = RatingSession();
    final updates = StreamController<SessionState>();
    whenListen(
      session,
      updates.stream,
      initialState: ratingSession(pending: 'ride'),
    );
    addTearDown(updates.close);
    addTearDown(session.close);
    when(
      () => repository.skipRating('ride'),
    ).thenAnswer((_) async => const Right(unit));
    final router = GoRouter(
      initialLocation: '/rate',
      routes: [
        GoRoute(path: '/rider', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/rate',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cubit),
              BlocProvider<SessionCubit>.value(value: session),
            ],
            child: RatingExit(
              child: Builder(
                builder: (context) => SingleChildScrollView(
                  child: RatingForm(
                    name: 'Driver',
                    onDone: () => RatingExit.finish(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
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
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/rate');
    updates.add(ratingSession());
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/rider');
  });
}
