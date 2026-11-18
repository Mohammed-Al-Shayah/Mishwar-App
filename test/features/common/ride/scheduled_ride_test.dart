import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart' show Timestamp;
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_search_pill.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/cancel_ride_result.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/request_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/schedule_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_scheduled_rides.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/ride_confirm_screen.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_screen.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/schedule_sheet.dart';
import 'package:mishwar/features/rider/ride/presentation/active_ride_listener.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';
import '../../history/history_data_cubit_test.dart'
    show
        MockCollection,
        MockDb,
        MockDoc,
        MockFunctions,
        MockQuery,
        MockQuerySnapshot;
import '../../history/history_widgets_test.dart' show historySize, historyWrap;
import '../../rider/confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, stubSuccess;
import 'ride_data_test.dart' show MockSource, rideJson;

void main() {
  final time = DateTime.utc(2026, 12, 1, 15, 30);
  final scheduledDraft = RideDraft(
    pickup: draft.pickup,
    dropoff: draft.dropoff,
    scheduledFor: time,
  );
  RideEntity scheduledRide() => RideModel.fromJson({
    ...rideJson(),
    'status': 'scheduled',
    'scheduledFor': Timestamp.fromDate(time),
  }).toEntity();

  test(
    'scheduled stream uses rider/status filters and departure order',
    () async {
      final db = MockDb();
      final collection = MockCollection();
      final query = MockQuery();
      final snapshot = MockQuerySnapshot();
      final doc = MockDoc();
      when(() => db.collection('rides')).thenReturn(collection);
      when(
        () => collection.where('riderId', isEqualTo: 'rider'),
      ).thenReturn(query);
      when(
        () => query.where('status', isEqualTo: 'scheduled'),
      ).thenReturn(query);
      when(() => query.orderBy('scheduledFor')).thenReturn(query);
      when(query.snapshots).thenAnswer((_) => Stream.value(snapshot));
      when(() => snapshot.docs).thenReturn([doc]);
      when(() => doc.id).thenReturn('ride');
      when(doc.data).thenReturn({
        ...rideJson(),
        'status': 'scheduled',
        'scheduledFor': Timestamp.fromDate(time),
      });
      final result = await WatchScheduledRides(
        RideRepositoryImpl(RideRemoteDataSource(MockFunctions(), db)),
      )('rider').first;
      expect(result.getRight().toNullable()!.single, scheduledRide());
      verify(() => query.orderBy('scheduledFor')).called(1);
    },
  );

  testWidgets('dispatch pointer navigates from activity to searching ride', (
    tester,
  ) async {
    historySize(tester);
    final rides = MockRideRepository();
    final updates = StreamController<Either<Failure, String?>>();
    when(
      () => rides.watchActiveRideId('rider'),
    ).thenAnswer((_) => updates.stream);
    final router = GoRouter(
      initialLocation: '/rider/history',
      routes: [
        GoRoute(
          path: '/rider/history',
          builder: (_, _) => ActiveRideListener(
            watch: WatchActiveRideId(rides),
            uid: 'rider',
            child: const Text('activity'),
          ),
        ),
        GoRoute(
          path: '/rider/ride/:id',
          builder: (_, state) =>
              Text('searching ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(() async {
      router.dispose();
      await updates.close();
    });
    await tester.pumpWidget(historyWrap(const SizedBox(), router: router));
    await tester.pumpAndSettle();
    updates.add(const Right(null));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/rider/history');
    updates.add(const Right('scheduled'));
    await tester.pumpAndSettle();
    expect(find.text('searching scheduled'), findsOneWidget);
  });

  test(
    'scheduled model, callable serialization and typed cap failure',
    () async {
      final source = MockSource();
      final repository = RideRepositoryImpl(source);
      Map<String, dynamic>? payload;
      when(() => source.schedule(any())).thenAnswer((invocation) async {
        payload = invocation.positionalArguments.first as Map<String, dynamic>;
        return 'scheduled';
      });
      expect(
        await ScheduleRide(repository)(scheduledDraft, VehicleType.comfort),
        const Right<Failure, String>('scheduled'),
      );
      expect(payload!['scheduledFor'], time.toIso8601String());
      expect(payload!['vehicleType'], 'comfort');
      expect(payload!.containsKey('fare'), isFalse);
      expect(scheduledRide().scheduledFor, time);
      expect(scheduledRide().status, RideStatus.scheduled);
      expect(RideModel.fromJson(rideJson()).scheduledFor, isNull);
      when(() => source.schedule(any())).thenThrow(
        FirebaseFunctionsException(
          message: 'Limit reached',
          code: 'failed-precondition',
          details: const {'reason': 'too-many-scheduled'},
        ),
      );
      expect(
        await ScheduleRide(repository)(scheduledDraft, VehicleType.economy),
        const Left<Failure, String>(
          SchedulingFailure(SchedulingFailureReason.tooManyScheduled),
        ),
      );
      when(() => source.scheduled('rider')).thenAnswer(
        (_) => Stream.value([
          RideModel.fromJson({
            ...rideJson(),
            'status': 'scheduled',
            'scheduledFor': Timestamp.fromDate(time),
          }),
        ]),
      );
      final result = await WatchScheduledRides(repository)('rider').first;
      expect(result.getRight().toNullable()!.single, scheduledRide());
    },
  );

  test(
    'confirmation schedules the selected vehicle; cap stays inline',
    () async {
      final rides = MockRideRepository();
      final routes = MockRouteRepository();
      stubSuccess(routes);
      when(
        () => rides.scheduleRide(scheduledDraft, VehicleType.van),
      ).thenAnswer(
        (_) async => const Left(
          SchedulingFailure(SchedulingFailureReason.tooManyScheduled),
        ),
      );
      final cubit = RideConfirmCubit(
        GetFareEstimates(routes),
        RequestRide(rides),
        scheduledDraft,
        validatePromo: promoValidatorStub(),
        scheduleRide: ScheduleRide(rides),
      );
      addTearDown(cubit.close);
      await cubit.start();
      cubit.select(VehicleType.van);
      await cubit.confirm();
      expect(
        (cubit.state as RideConfirmLoaded).requestFailure,
        isA<SchedulingFailure>(),
      );
      when(
        () => rides.scheduleRide(scheduledDraft, VehicleType.van),
      ).thenAnswer((_) async => const Right('scheduled'));
      await cubit.confirm();
      expect((cubit.state as RideConfirmRequested).rideId, 'scheduled');
      verifyNever(() => rides.requestRide(scheduledDraft, VehicleType.van));
    },
  );

  for (final language in ['ar', 'en']) {
    for (final dark in [false, true]) {
      testWidgets(
        'schedule picker and clear action $language dark=$dark at 1.3',
        (tester) async {
          historySize(tester);
          DateTime? selected;
          await tester.pumpWidget(
            historyWrap(
              Scaffold(
                body: Builder(
                  builder: (context) => MwSearchPill(
                    onSchedule: () async {
                      selected = await showScheduleSheet(context, null);
                    },
                  ),
                ),
              ),
              language: language,
              dark: dark,
            ),
          );
          await tester.tap(find.text(language == 'ar' ? 'لاحقاً' : 'Later'));
          await tester.pumpAndSettle();
          final picker = tester.widget<CupertinoDatePicker>(
            find.byType(CupertinoDatePicker),
          );
          expect(picker.minuteInterval, 5);
          expect(
            picker.initialDateTime.isBefore(
              DateTime.now().add(const Duration(minutes: 30)),
            ),
            isFalse,
          );
          await tester.tap(find.text(language == 'ar' ? 'بكرا' : 'Tomorrow'));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(MwPrimaryButton));
          await tester.pumpAndSettle();
          expect(
            DateUtils.isSameDay(
              selected,
              DateTime.now().add(const Duration(days: 1)),
            ),
            isTrue,
          );
          expect(selected!.minute % 5, 0);
          var cleared = false;
          await tester.pumpWidget(
            historyWrap(
              Scaffold(
                body: MwSearchPill(
                  scheduleLabel: language == 'ar'
                      ? 'الخميس 3:30 م'
                      : 'Thursday 3:30 PM',
                  onClearSchedule: () => cleared = true,
                ),
              ),
              language: language,
              dark: dark,
            ),
          );
          await tester.tap(find.byType(IconButton));
          expect(cleared, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets('scheduled activity confirms cancellation $language at 1.3', (
      tester,
    ) async {
      historySize(tester);
      final rides = MockRideRepository();
      when(
        () => rides.history(party: RideParty.rider, uid: 'rider'),
      ).thenAnswer((_) async => Right(RideHistoryPage(items: [])));
      final updates = StreamController<Either<Failure, List<RideEntity>>>();
      when(
        () => rides.watchScheduledRides('rider'),
      ).thenAnswer((_) => updates.stream);
      when(() => rides.cancelRide('ride')).thenAnswer(
        (_) async => const Right(CancelRideResult()),
      );
      final cubit = RideHistoryCubit(
        GetRideHistory(rides),
        watchScheduledRides: WatchScheduledRides(rides),
        cancelRide: CancelRide(rides),
      );
      addTearDown(() async {
        await cubit.close();
        await updates.close();
      });
      await cubit.loadFirst('rider');
      updates.add(Right([scheduledRide()]));
      await tester.pumpWidget(
        historyWrap(
          BlocProvider.value(value: cubit, child: const RideHistoryScreen()),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(language == 'ar' ? 'المجدولة' : 'Scheduled'),
        findsOneWidget,
      );
      expect(find.text('Dropoff'), findsOneWidget);
      await tester.tap(find.text(language == 'ar' ? 'إلغاء' : 'Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => rides.cancelRide('ride'));
      await tester.tap(find.byType(MwPrimaryButton));
      await tester.pumpAndSettle();
      verify(() => rides.cancelRide('ride')).called(1);
      expect(cubit.state.scheduled, isEmpty);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'scheduled confirmation navigates to activity $language at 1.3',
      (tester) async {
        historySize(tester);
        final rides = MockRideRepository();
        final routes = MockRouteRepository();
        stubSuccess(routes);
        when(
          () => rides.scheduleRide(scheduledDraft, VehicleType.economy),
        ).thenAnswer(
          (_) async => const Left(
            SchedulingFailure(SchedulingFailureReason.tooManyScheduled),
          ),
        );
        final router = GoRouter(
          initialLocation: '/rider/confirm',
          routes: [
            GoRoute(
              path: '/rider/confirm',
              builder: (_, _) => BlocProvider(
                create: (_) => RideConfirmCubit(
                  GetFareEstimates(routes),
                  RequestRide(rides),
                  scheduledDraft,
                  validatePromo: promoValidatorStub(),
                  scheduleRide: ScheduleRide(rides),
                ),
                child: RideConfirmScreen(
                  draft: scheduledDraft,
                  mapBuilder: (_) => const MwMapPlaceholder(),
                ),
              ),
            ),
            GoRoute(
              path: '/rider/history',
              builder: (_, _) => const Scaffold(body: Text('activity')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          historyWrap(const SizedBox(), language: language, router: router),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            language == 'ar' ? 'موعد الانطلاق' : 'Departure time',
          ),
          findsOneWidget,
        );
        await tester.tap(find.byType(MwPrimaryButton));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          '/rider/confirm',
        );
        expect(
          find.textContaining(
            language == 'ar' ? '3 مشاوير' : '3 scheduled rides',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        when(
          () => rides.scheduleRide(scheduledDraft, VehicleType.economy),
        ).thenAnswer((_) async => const Right('scheduled'));
        await tester.tap(find.byType(MwPrimaryButton));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          '/rider/history',
        );
        expect(
          find.text(language == 'ar' ? 'انحجز مشوارك' : 'Your ride is booked'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
