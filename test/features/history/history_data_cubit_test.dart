// Firestore sealed types are mocked only to verify query construction.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_cubit.dart';
import 'package:mishwar/features/driver/earnings/data/earnings_remote_data_source.dart';
import 'package:mishwar/features/driver/earnings/data/earnings_repository_impl.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/earnings_repository.dart';
import 'package:mishwar/features/driver/earnings/domain/get_week_earnings.dart';
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';
import '../common/ride/ride_data_test.dart' show rideJson;

class MockDb extends Mock implements FirebaseFirestore {}

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockRef extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockRides extends Mock implements RideRepository {}

class MockEarnings extends Mock implements EarningsRepository {}

class Cursor extends HistoryCursor {}

RideEntity historyRide(
  String id, {
  DateTime? createdAt,
  DateTime? completedAt,
}) => RideModel.fromJson({
  ...rideJson(),
  'id': id,
  'status': 'completed',
  'createdAt': Timestamp.fromDate(createdAt ?? DateTime.utc(2026, 11, 17)),
  if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt),
  'driverRating': {'stars': 4},
  'riderRating': {'stars': 5},
  'driverInfo': {
    'name': 'Driver',
    'phone': '',
    'vehicle': {
      'type': 'economy',
      'make': 'Toyota',
      'model': 'Corolla',
      'color': 'White',
      'plate': '12-345',
    },
  },
  'riderInfo': {'name': 'Rider', 'phone': ''},
}).toEntity();

void main() {
  setUpAll(() {
    registerFallbackValue(RideParty.rider);
    registerFallbackValue(Cursor());
    registerFallbackValue(DateTime.utc(2026));
  });
  for (final party in RideParty.values) {
    test(
      'history query shape and opaque pagination for ${party.name}',
      () async {
        final db = MockDb();
        final collection = MockCollection();
        final query = MockQuery();
        final snapshot = MockQuerySnapshot();
        final docs = List.generate(3, (i) {
          final doc = MockDoc();
          when(() => doc.id).thenReturn('ride$i');
          when(
            doc.data,
          ).thenReturn({...rideJson(), 'status': 'completed'});
          return doc;
        });
        when(() => db.collection('rides')).thenReturn(collection);
        when(
          () => collection.where('${party.name}Id', isEqualTo: 'u'),
        ).thenReturn(query);
        when(
          () => query.where(
            'status',
            whereIn: ['completed', 'cancelled', 'no_drivers'],
          ),
        ).thenReturn(query);
        when(
          () => query.orderBy('createdAt', descending: true),
        ).thenReturn(query);
        when(() => query.limit(3)).thenReturn(query);
        when(query.get).thenAnswer((_) async => snapshot);
        when(() => snapshot.docs).thenReturn(docs);
        final repository = RideRepositoryImpl(
          RideRemoteDataSource(MockFunctions(), db),
        );
        final result = await repository.history(
          party: party,
          uid: 'u',
          limit: 2,
        );
        final page = result.getRight().toNullable()!;
        expect(page.items.map((r) => r.id), ['ride0', 'ride1']);
        expect(page.items.first.status, RideStatus.completed);
        expect(page.next, isA<HistoryCursor>());
        when(() => query.startAfterDocument(docs[1])).thenReturn(query);
        when(() => snapshot.docs).thenReturn([docs[2]]);
        final last = (await repository.history(
          party: party,
          uid: 'u',
          limit: 2,
          after: page.next,
        )).getRight().toNullable()!;
        expect(last.items.single.id, 'ride2');
        expect(last.hasMore, false);
        verify(() => query.startAfterDocument(docs[1])).called(1);
        verify(() => query.orderBy('createdAt', descending: true)).called(2);
        final invalid = await repository.history(
          party: party,
          uid: 'other',
          after: page.next,
        );
        expect(invalid.isLeft(), true);
      },
    );
  }

  test('UTC 21:30 is next Amman day, including year boundary', () {
    expect(
      earningsDayKey(ammanDay(DateTime.utc(2026, 12, 31, 21, 30))),
      '2027-01-01',
    );
    expect(
      earningsDayKey(ammanDay(DateTime.utc(2026, 11, 17, 20, 59))),
      '2026-11-17',
    );
  });
  test(
    'seven earnings docs assemble oldest first with missing docs zero',
    () async {
      final db = MockDb();
      final end = DateTime.utc(2026, 11, 17);
      final source = EarningsRemoteDataSource(db);
      for (var i = 0; i < 7; i++) {
        final day = end.subtract(Duration(days: i));
        final ref = MockRef();
        final snapshot = MockSnapshot();
        when(
          () => db.doc('drivers/u/earnings/${earningsDayKey(day)}'),
        ).thenReturn(ref);
        when(ref.get).thenAnswer((_) async => snapshot);
        when(
          snapshot.data,
        ).thenReturn(i == 0 ? {'total': 4.75, 'trips': 2} : null);
        when(ref.snapshots).thenAnswer((_) => Stream.value(snapshot));
      }
      final repo = EarningsRepositoryImpl(source);
      final week = (await repo.week('u', end)).getRight().toNullable()!;
      expect(week.length, 7);
      expect(week.first.day, DateTime.utc(2026, 11, 11));
      expect(week.take(6).every((d) => d.totalFils == 0 && d.trips == 0), true);
      expect(week.last, DailyEarnings(day: end, totalFils: 4750, trips: 2));
      expect(
        (await repo.watchDay('u', end).first).getRight().toNullable(),
        week.last,
      );
      when(() => db.doc(any())).thenThrow(StateError('offline'));
      expect((await repo.week('u', end)).isLeft(), true);
      expect((await repo.watchDay('u', end).first).isLeft(), true);
    },
  );
  test('history first, more, end, failure, retry and empty', () async {
    final rides = MockRides();
    final cursor = Cursor();
    final cubit = RideHistoryCubit(
      GetRideHistory(rides),
      watchScheduledRides: emptyScheduledRidesWatch(),
      cancelRide: cancelRideStub(),
    );
    addTearDown(cubit.close);
    when(() => rides.history(party: RideParty.rider, uid: 'u')).thenAnswer(
      (_) async =>
          Right(RideHistoryPage(items: [historyRide('1')], next: cursor)),
    );
    when(
      () => rides.history(party: RideParty.rider, uid: 'u', after: cursor),
    ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
    await cubit.loadFirst('u');
    expect(cubit.state.items.single.id, '1');
    expect(cubit.state.hasMore, true);
    await cubit.loadMore();
    expect(cubit.state.failure, const NetworkFailure('offline'));
    expect(cubit.state.items.length, 1);
    when(
      () => rides.history(party: RideParty.rider, uid: 'u', after: cursor),
    ).thenAnswer(
      (_) async => Right(RideHistoryPage(items: [historyRide('2')])),
    );
    await cubit.loadMore();
    expect(cubit.state.items.map((r) => r.id), ['1', '2']);
    expect(cubit.state.hasMore, false);
    await cubit.loadMore();
    verify(
      () => rides.history(party: RideParty.rider, uid: 'u', after: cursor),
    ).called(2);
    when(
      () => rides.history(party: RideParty.rider, uid: 'u'),
    ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
    await cubit.refresh();
    expect(cubit.state.status, HistoryStatus.failure);
    when(
      () => rides.history(party: RideParty.rider, uid: 'u'),
    ).thenAnswer((_) async => Right(RideHistoryPage(items: [])));
    await cubit.refresh();
    expect(cubit.state.status, HistoryStatus.empty);
  });
  test('refresh discards an older in-flight page', () async {
    final rides = MockRides();
    final pending = Completer<Either<Failure, RideHistoryPage>>();
    final cubit = RideHistoryCubit(
      GetRideHistory(rides),
      watchScheduledRides: emptyScheduledRidesWatch(),
      cancelRide: cancelRideStub(),
    );
    addTearDown(cubit.close);
    when(
      () => rides.history(party: RideParty.rider, uid: 'u'),
    ).thenAnswer((_) => pending.future);
    final first = cubit.loadFirst('u');
    when(
      () => rides.history(party: RideParty.rider, uid: 'u'),
    ).thenAnswer((_) async => Right(RideHistoryPage(items: [])));
    await cubit.refresh();
    pending.complete(Right(RideHistoryPage(items: [historyRide('stale')])));
    await first;
    expect(cubit.state.status, HistoryStatus.empty);
  });
  test(
    'earnings selects day, traverses pages and uses completion date',
    () async {
      final earnings = MockEarnings();
      final rides = MockRides();
      final end = DateTime.utc(2026, 11, 17);
      final days = List.generate(
        7,
        (i) => DailyEarnings(day: end.subtract(Duration(days: 6 - i))),
      );
      final live = StreamController<Either<Failure, DailyEarnings>>.broadcast();
      addTearDown(live.close);
      when(() => earnings.week('u', end)).thenAnswer((_) async => Right(days));
      when(() => earnings.watchDay('u', any())).thenAnswer((_) => live.stream);
      final cursor = Cursor();
      when(() => rides.history(party: RideParty.driver, uid: 'u')).thenAnswer(
        (_) async => Right(RideHistoryPage(items: [], next: cursor)),
      );
      when(
        () => rides.history(party: RideParty.driver, uid: 'u', after: cursor),
      ).thenAnswer(
        (_) async => Right(
          RideHistoryPage(
            items: [
              historyRide(
                'overnight',
                createdAt: DateTime.utc(2026, 11, 16, 20),
                completedAt: DateTime.utc(2026, 11, 16, 21, 30),
              ),
            ],
          ),
        ),
      );
      final cubit = EarningsScreenCubit(
        GetWeekEarnings(earnings),
        WatchDayEarnings(earnings),
        GetRideHistory(rides),
      );
      addTearDown(cubit.close);
      await cubit.load('u', endingOn: end);
      expect(cubit.state.trips.single.id, 'overnight');
      live.add(Right(DailyEarnings(day: end, totalFils: 7500, trips: 1)));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.selectedEarnings!.totalFils, 7500);
      await cubit.selectDay(days.first.day);
      expect(cubit.state.selected, days.first.day);
      expect(cubit.state.trips, isEmpty);
      when(
        () => earnings.week('u', end),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      await cubit.load('u', endingOn: end);
      expect(cubit.state.failure, const NetworkFailure('offline'));
    },
  );
  test('home earnings emits live changes and cancels on close', () async {
    final repository = MockEarnings();
    final live = StreamController<Either<Failure, DailyEarnings>>.broadcast();
    when(() => repository.watchDay('u', any())).thenAnswer((_) => live.stream);
    final cubit = DriverEarningsCubit(WatchDayEarnings(repository));
    await cubit.start('u');
    final day = ammanDay(DateTime.now());
    live.add(Right(DailyEarnings(day: day, totalFils: 12000)));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.earnings!.totalFils, 12000);
    await cubit.close();
    expect(live.hasListener, false);
    await live.close();
  });
  test('receipt streams ride and supports failure retry', () async {
    final repository = MockRides();
    when(
      () => repository.watchRide('1'),
    ).thenAnswer((_) => Stream.value(const Left(NetworkFailure('offline'))));
    final cubit = RideReceiptCubit(WatchRide(repository));
    addTearDown(cubit.close);
    await cubit.load('1');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.failure, const NetworkFailure('offline'));
    when(
      () => repository.watchRide('1'),
    ).thenAnswer((_) => Stream.value(Right(historyRide('1'))));
    await cubit.load('1');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.ride!.driverRating, 4);
    expect(cubit.state.ride!.riderRating, 5);
  });
}
