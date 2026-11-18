import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_ar.dart';
import 'package:mishwar/core/l10n/gen/app_localizations_en.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart'
    as presence;
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart';
import 'package:mishwar/features/driver/trip/presentation/driver_trip_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../presence/driver_home_screen_test.dart'
    show MockPresenceBloc, map, size, wrap;
import 'driver_trip_bloc_test.dart';

void main() {
  setUpAll(() => registerFallbackValue(const Started()));
  for (final language in ['ar', 'en']) {
    final l10n = language == 'ar' ? AppLocalizationsAr() : AppLocalizationsEn();
    testWidgets('paid waiting $language scale 1.3', (tester) async {
      size(tester);
      final bloc = MockTripBloc();
      whenListen(
        bloc,
        const Stream<DriverTripState>.empty(),
        initialState: DriverTripState(
          ride: tripRide(RideStatus.arrived),
          phase: TripPhase.waiting,
          waitingElapsed: const Duration(seconds: 241),
        ),
      );
      final presenceBloc = MockPresenceBloc();
      whenListen(
        presenceBloc,
        const Stream<presence.DriverPresenceState>.empty(),
        initialState: const presence.DriverPresenceState(),
      );
      await tester.pumpWidget(
        wrap(
          MultiBlocProvider(
            providers: [
              BlocProvider<DriverTripBloc>.value(value: bloc),
              BlocProvider<presence.DriverPresenceBloc>.value(
                value: presenceBloc,
              ),
            ],
            child: const DriverTripScreen(mapBuilder: map),
          ),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('JD 0.10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    for (final phase in [
      TripPhase.toPickup,
      TripPhase.waiting,
      TripPhase.onTrip,
      TripPhase.collectCash,
    ]) {
      for (final busy in [false, true]) {
        testWidgets('trip $phase $language busy=$busy scale 1.3', (
          tester,
        ) async {
          size(tester);
          final bloc = MockTripBloc();
          final status = switch (phase) {
            TripPhase.toPickup => RideStatus.arriving,
            TripPhase.waiting => RideStatus.arrived,
            TripPhase.onTrip => RideStatus.inProgress,
            _ => RideStatus.completed,
          };
          whenListen(
            bloc,
            const Stream<DriverTripState>.empty(),
            initialState: DriverTripState(
              ride: tripRide(status),
              phase: phase,
              busy: busy,
              waitingElapsed: const Duration(seconds: 133),
              failure: phase == TripPhase.toPickup
                  ? const RideActionFailure(RideActionFailureReason.tooFar)
                  : null,
            ),
          );
          final presenceBloc = MockPresenceBloc();
          whenListen(
            presenceBloc,
            const Stream<presence.DriverPresenceState>.empty(),
            initialState: const presence.DriverPresenceState(),
          );
          final uris = <Uri>[];
          await tester.pumpWidget(
            wrap(
              MultiBlocProvider(
                providers: [
                  BlocProvider<DriverTripBloc>.value(value: bloc),
                  BlocProvider<presence.DriverPresenceBloc>.value(
                    value: presenceBloc,
                  ),
                ],
                child: DriverTripScreen(
                  mapBuilder: map,
                  launcher: (uri) async {
                    uris.add(uri);
                    return uri.scheme == 'tel';
                  },
                ),
              ),
              language: language,
            ),
          );
          if (busy) {
            await tester.pump();
          } else {
            await tester.pumpAndSettle();
          }
          final label = switch (phase) {
            TripPhase.toPickup => l10n.tripArrived,
            TripPhase.waiting => l10n.tripStart,
            TripPhase.onTrip => l10n.tripComplete,
            _ => l10n.tripCashCollected,
          };
          expect(
            Theme.of(
              tester.element(find.byKey(const Key('driver_map'))),
            ).brightness,
            Brightness.dark,
          );
          if (!busy) {
            expect(find.text(label), findsOneWidget);
            if (phase == TripPhase.waiting) {
              expect(find.text(l10n.tripWaitingTime('2:13')), findsOneWidget);
            }
            if (phase == TripPhase.collectCash) {
              expect(find.text(l10n.tripPrice('5.25')), findsOneWidget);
            }
            if (phase == TripPhase.toPickup) {
              expect(find.text(l10n.tripTooFar), findsOneWidget);
            }
            await tester.tap(find.text(label));
            if (busy) {
              await tester.pump();
            } else {
              await tester.pumpAndSettle();
            }
            if (phase == TripPhase.onTrip) {
              expect(find.text(l10n.tripCompleteConfirm), findsOneWidget);
              verifyNever(() => bloc.add(any(that: isA<CompletePressed>())));
              await tester.tap(find.text(l10n.tripNo));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              await tester.tap(find.text(label));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              await tester.tap(find.text(label).last);
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              verify(
                () => bloc.add(any(that: isA<CompletePressed>())),
              ).called(1);
              final mwMap = tester.widget<MwMap>(find.byType(MwMap));
              expect(mwMap.polylines.single.points, hasLength(3));
            } else {
              verify(
                () => bloc.add(
                  any(
                    that: phase == TripPhase.toPickup
                        ? isA<ArrivedPressed>()
                        : phase == TripPhase.waiting
                        ? isA<StartPressed>()
                        : isA<CashCollectedPressed>(),
                  ),
                ),
              ).called(1);
            }
            if (phase != TripPhase.collectCash) {
              debugDefaultTargetPlatformOverride = TargetPlatform.android;
              await tester.tap(find.byTooltip(l10n.tripNavigate));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              debugDefaultTargetPlatformOverride = null;
              final target = phase == TripPhase.onTrip
                  ? tripRide(status).dropoff.location
                  : tripRide(status).pickup.location;
              expect(
                uris[0].toString(),
                'google.navigation:q=${target.lat},${target.lng}&mode=d',
              );
              expect(
                uris[1].toString(),
                'https://www.google.com/maps/dir/?api=1&destination=${target.lat},${target.lng}&travelmode=driving',
              );
              await tester.tap(find.byTooltip(l10n.tripCall));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              expect(uris.last.toString(), 'tel:+962791234567');
            }
            if (phase == TripPhase.toPickup || phase == TripPhase.waiting) {
              await tester.tap(find.byTooltip(l10n.tripMore));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              await tester.tap(find.text(l10n.tripCancel));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              expect(find.text(l10n.tripCancelConfirm), findsOneWidget);
              verifyNever(() => bloc.add(any(that: isA<CancelPressed>())));
              await tester.tap(find.text(l10n.tripCancel));
              if (busy) {
                await tester.pump();
              } else {
                await tester.pumpAndSettle();
              }
              verify(() => bloc.add(any(that: isA<CancelPressed>()))).called(1);
            }
          } else {
            expect(find.byType(CircularProgressIndicator), findsOneWidget);
            expect(
              tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
              isNull,
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
    for (final phase in [
      TripPhase.done,
      TripPhase.cancelled,
      TripPhase.redispatched,
    ]) {
      testWidgets('trip $phase returns home $language', (tester) async {
        size(tester);
        final bloc = MockTripBloc();
        final initial = DriverTripState(
          ride: tripRide(RideStatus.completed),
          phase: TripPhase.collectCash,
        );
        final controller = StreamController<DriverTripState>();
        whenListen(bloc, controller.stream, initialState: initial);
        final presenceBloc = MockPresenceBloc();
        whenListen(
          presenceBloc,
          const Stream<presence.DriverPresenceState>.empty(),
          initialState: const presence.DriverPresenceState(),
        );
        final router = GoRouter(
          initialLocation: '/driver/ride/ride',
          routes: [
            GoRoute(
              path: '/driver',
              builder: (_, _) => const Scaffold(body: Text('home')),
            ),
            GoRoute(
              path: '/driver/ride/:id',
              routes: [
                GoRoute(
                  path: 'rate',
                  builder: (_, _) => const Scaffold(body: Text('rate')),
                ),
              ],
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider<DriverTripBloc>.value(value: bloc),
                  BlocProvider<presence.DriverPresenceBloc>.value(
                    value: presenceBloc,
                  ),
                ],
                child: const DriverTripScreen(mapBuilder: map),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);
        addTearDown(controller.close);
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
        controller.add(DriverTripState(ride: initial.ride, phase: phase));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          phase == TripPhase.done ? '/driver/ride/ride/rate' : '/driver',
        );
        if (phase != TripPhase.done) {
          expect(
            find.text(
              phase == TripPhase.cancelled
                  ? l10n.tripCancelled
                  : l10n.tripRedispatched,
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
