import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/domain/support_usecases.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mishwar/features/common/support/presentation/support_screens.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../history/history_data_cubit_test.dart' show MockRides, historyRide;
import '../history/history_widgets_test.dart' show historySize, historyWrap;
import 'support_test.dart';

class MockHistoryCubit extends MockCubit<RideHistoryState>
    implements RideHistoryCubit {}

void main() {
  testWidgets('cancelled receipt includes actor and fee in shared text', (
    tester,
  ) async {
    historySize(tester);
    final original = historyRide('t');
    final ride = RideEntity(
      id: original.id,
      riderId: original.riderId,
      status: RideStatus.cancelled,
      vehicleType: original.vehicleType,
      pickup: original.pickup,
      dropoff: original.dropoff,
      fareEstimatedMinor: original.fareEstimatedMinor,
      createdAt: original.createdAt,
      cancelledBy: 'driver',
      fareCancellationFeeMinor: 1500,
    );
    await tester.pumpWidget(
      historyWrap(Scaffold(body: RideReceiptContent(ride: ride))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cancelled by the driver'), findsOneWidget);
    expect(find.text('Cancellation fee'), findsOneWidget);
    final text = receiptText(
      tester.element(find.byType(RideReceiptContent)),
      ride,
    );
    expect(text, contains('Cancelled by the driver'));
    expect(text, contains('Cancellation fee: JD 1.50'));
  });
  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets('support list $language dark=$dark scale 1.3', (
        tester,
      ) async {
        historySize(tester);
        final repo = MockSupport();
        when(
          () => repo.watchTickets(uid: 'u'),
        ).thenAnswer((_) => Stream.value(Right([ticket()])));
        final cubit = SupportListCubit(WatchSupportTickets(repo));
        addTearDown(() => tester.runAsync(cubit.close));
        await cubit.start(uid: 'u');
        await tester.pumpWidget(
          historyWrap(
            BlocProvider.value(
              value: cubit,
              child: SupportListScreen(uid: 'u', driver: dark),
            ),
            language: language,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SupportStatusPill), findsOneWidget);
        expect(
          find.text(language == 'ar' ? 'طلب مساعدة جديد' : 'New help request'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
      testWidgets('support new and thread $language dark=$dark scale 1.3', (
        tester,
      ) async {
        historySize(tester);
        final repo = MockSupport();
        final rides = MockRides();
        final cubit = NewSupportCubit(
          CreateSupportTicket(repo),
          WatchRide(rides),
        );
        addTearDown(() => tester.runAsync(cubit.close));
        await tester.pumpWidget(
          historyWrap(
            BlocProvider.value(
              value: cubit,
              child: NewSupportScreen(driver: dark),
            ),
            language: language,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNWidgets(4));
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.maxLines, 8);
        await tester.enterText(
          find.byType(TextField),
          'Please help with this trip',
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        stubThread(repo);
        when(() => repo.watchMessages('t')).thenAnswer(
          (_) => Stream.value(
            Right([
              SupportMessage(
                id: '1',
                from: 'user',
                text: 'My message',
                createdAt: DateTime(2026),
              ),
              SupportMessage(
                id: '2',
                from: 'admin',
                text: 'Support reply',
                createdAt: DateTime(2026),
              ),
            ]),
          ),
        );
        final conversation = thread(repo);
        addTearDown(() => tester.runAsync(conversation.close));
        await tester.runAsync(() => conversation.start('t'));
        await tester.pumpWidget(
          historyWrap(
            BlocProvider.value(
              value: conversation,
              child: SupportThreadScreen(driver: dark),
            ),
            language: language,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('My message'), findsOneWidget);
        expect(find.text('Support reply'), findsOneWidget);
        expect(find.byType(MwTextField), findsOneWidget);
        expect(tester.takeException(), isNull);
        stubThread(repo, status: SupportStatus.closed, unread: false);
        await tester.runAsync(() => conversation.start('t'));
        await tester.pumpAndSettle();
        expect(find.byType(MwTextField), findsNothing);
        expect(
          find.text(
            language == 'ar'
                ? 'هالطلب مسكّر. إذا لسا بدك مساعدة افتح طلب جديد.'
                : 'This request is closed. You can open a new help request.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets(
      'activity defaults to upcoming and switches to past $language',
      (tester) async {
        historySize(tester);
        final cubit = MockHistoryCubit();
        whenListen(
          cubit,
          const Stream<RideHistoryState>.empty(),
          initialState: RideHistoryState(
            scheduled: [historyRide('scheduled')],
            items: [historyRide('past')],
            status: HistoryStatus.loaded,
          ),
        );
        await tester.pumpWidget(
          historyWrap(
            BlocProvider<RideHistoryCubit>.value(
              value: cubit,
              child: const RideHistoryScreen(),
            ),
            language: language,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>))
              .selected,
          {true},
        );
        await tester.tap(find.text(language == 'ar' ? 'السابقة' : 'Past'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>))
              .selected,
          {false},
        );
        expect(
          tester.widget<HistoryRideRow>(find.byType(HistoryRideRow)).ride.id,
          'past',
        );
        expect(tester.takeException(), isNull);
        await cubit.close();
      },
    );
  }
  for (final driver in [false, true]) {
    testWidgets('receipt report deep link driver=$driver and plain-text fare', (
      tester,
    ) async {
      historySize(tester);
      String? rideId;
      final ride = historyRide('trip');
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: RideReceiptContent(ride: ride, driver: driver),
            ),
          ),
          GoRoute(
            path: '/${driver ? 'driver' : 'rider'}/support/new',
            builder: (_, state) {
              rideId = state.uri.queryParameters['rideId'];
              return const Scaffold();
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(historyWrap(const SizedBox(), router: router));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(RideReceiptContent));
      final text = receiptText(context, ride);
      expect(text, contains('JD 2.55'));
      expect(text, contains('Pickup'));
      expect(text, contains('Dropoff'));
      expect(text, contains('Cash'));
      await tester.ensureVisible(find.text('Report a problem'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report a problem'));
      await tester.pumpAndSettle();
      expect(rideId, 'trip');
    });
  }
}
