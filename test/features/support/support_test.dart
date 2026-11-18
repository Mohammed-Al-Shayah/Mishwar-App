import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/notifications/data/push_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/support/data/support_model.dart';
import 'package:mishwar/features/common/support/data/support_remote_data_source.dart';
import 'package:mishwar/features/common/support/data/support_repository_impl.dart';
import 'package:mishwar/features/common/support/domain/support_repository.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/domain/support_usecases.dart';
import 'package:mishwar/features/common/support/presentation/support_cubits.dart';
import 'package:mocktail/mocktail.dart';

import '../history/history_data_cubit_test.dart' show MockRides, historyRide;

class MockSupport extends Mock implements SupportRepository {}

class MockSupportSource extends Mock implements SupportRemoteDataSource {}

SupportTicket ticket({
  SupportStatus status = SupportStatus.open,
  bool unread = true,
}) => SupportTicket(
  id: 't',
  uid: 'u',
  role: 'rider',
  category: SupportCategory.fare,
  subject: 'السعر',
  status: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  lastMessageAt: DateTime(2026),
  lastMessageBy: 'admin',
  userUnread: unread,
);
SupportThreadCubit thread(MockSupport repository) => SupportThreadCubit(
  WatchSupportTicket(repository),
  WatchSupportMessages(repository),
  SendSupportMessage(repository),
  MarkSupportRead(repository),
  SetSupportStatus(repository),
);
void stubThread(
  MockSupport repository, {
  SupportStatus status = SupportStatus.open,
  bool unread = true,
}) {
  when(() => repository.watchTicket('t')).thenAnswer(
    (_) => Stream.value(Right(ticket(status: status, unread: unread))),
  );
  when(
    () => repository.watchMessages('t'),
  ).thenAnswer((_) => Stream.value(const Right([])));
  when(
    () => repository.markRead('t'),
  ).thenAnswer((_) async => const Right(unit));
}

void main() {
  setUpAll(() {
    registerFallbackValue(SupportCategory.other);
    registerFallbackValue(SupportStatus.open);
  });
  test('models convert timestamps, wire enums and pending messages', () {
    final at = Timestamp.fromDate(DateTime.utc(2026));
    final model = SupportTicketModel.fromJson({
      'id': 't',
      'uid': 'u',
      'role': 'driver',
      'rideId': 'r',
      'category': 'lost_item',
      'subject': 'أغراض منسية',
      'status': 'in_progress',
      'createdAt': at,
      'updatedAt': at,
      'lastMessageAt': at,
      'lastMessageBy': 'admin',
      'userUnread': true,
    });
    expect(model.toEntity().category, SupportCategory.lostItem);
    expect(model.toEntity().status, SupportStatus.inProgress);
    expect(model.toEntity().rideId, 'r');
    expect(
      SupportMessageModel.fromJson({
        'id': 'm',
        'from': 'user',
        'text': 'hi',
        'createdAt': null,
      }).toEntity().createdAt,
      isNull,
    );
  });
  test(
    'use cases reject empty/oversized messages and trim valid input',
    () async {
      final repo = MockSupport();
      final create = CreateSupportTicket(repo);
      final send = SendSupportMessage(repo);
      for (final text in ['', '   ', 'a' * 1001]) {
        expect((await create(SupportCategory.fare, text)).isLeft(), isTrue);
        expect((await send('t', text)).isLeft(), isTrue);
      }
      when(
        () => repo.create(SupportCategory.fare, 'help', rideId: 'r'),
      ).thenAnswer((_) async => const Right('t'));
      expect(
        await create(SupportCategory.fare, ' help ', rideId: 'r'),
        const Right<Failure, String>('t'),
      );
      when(
        () => repo.send('t', 'reply', admin: true),
      ).thenAnswer((_) async => const Right(unit));
      expect((await send('t', ' reply ', admin: true)).isRight(), isTrue);
    },
  );
  test(
    'repository maps callable cap and stream exceptions to Failure',
    () async {
      final source = MockSupportSource();
      final repo = SupportRepositoryImpl(source);
      when(() => source.create(SupportCategory.other, 'help')).thenThrow(
        FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'cap',
          details: const {'reason': 'too-many-open'},
        ),
      );
      expect(
        await repo.create(SupportCategory.other, 'help'),
        const Left<Failure, String>(ValidationFailure('support-limit')),
      );
      when(
        () => source.watchMessages('t'),
      ).thenAnswer((_) => Stream.error(StateError('offline')));
      expect((await repo.watchMessages('t').first).isLeft(), isTrue);
    },
  );
  blocTest<SupportListCubit, SupportListState>(
    'list exposes unread and supports status filter',
    build: () {
      final repo = MockSupport();
      when(
        () => repo.watchTickets(uid: 'u', status: SupportStatus.open),
      ).thenAnswer((_) => Stream.value(Right([ticket()])));
      return SupportListCubit(WatchSupportTickets(repo));
    },
    act: (cubit) => cubit.start(uid: 'u', status: SupportStatus.open),
    expect: () => [
      const SupportListState(filter: SupportStatus.open),
      isA<SupportListState>()
          .having((s) => s.unread, 'unread', true)
          .having((s) => s.loading, 'loaded', false),
    ],
  );
  test(
    'new ticket loads ride, changes category, sends ride ID and handles cap',
    () async {
      final repo = MockSupport();
      final rides = MockRides();
      when(
        () => rides.watchRide('r'),
      ).thenAnswer((_) => Stream.value(Right(historyRide('r'))));
      when(
        () => repo.create(SupportCategory.safety, 'help', rideId: 'r'),
      ).thenAnswer((_) async => const Left(ValidationFailure('support-limit')));
      final cubit = NewSupportCubit(
        CreateSupportTicket(repo),
        WatchRide(rides),
      )..start('r');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.ride?.id, 'r');
      cubit.select(SupportCategory.safety);
      expect(await cubit.submit('help'), isNull);
      expect(cubit.state.failure, const ValidationFailure('support-limit'));
      await cubit.close();
    },
  );
  test(
    'thread marks unread on open, sends as user; closed cannot send',
    () async {
      final repo = MockSupport();
      stubThread(repo);
      when(
        () => repo.send('t', 'hello'),
      ).thenAnswer((_) async => const Right(unit));
      final cubit = thread(repo);
      await cubit.start('t');
      await Future<void>.delayed(Duration.zero);
      verify(() => repo.markRead('t')).called(1);
      expect(await cubit.send('hello'), isTrue);
      verify(() => repo.send('t', 'hello')).called(1);
      await cubit.close();
      stubThread(repo, status: SupportStatus.closed, unread: false);
      final closed = thread(repo);
      await closed.start('t');
      await Future<void>.delayed(Duration.zero);
      expect(await closed.send('hello'), isFalse);
      await closed.close();
    },
  );
  test(
    'admin thread never marks read, replies via admin and changes status',
    () async {
      final repo = MockSupport();
      stubThread(repo);
      when(
        () => repo.send('t', 'reply', admin: true),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repo.setStatus('t', SupportStatus.closed),
      ).thenAnswer((_) async => const Right(unit));
      final cubit = thread(repo);
      await cubit.start('t', admin: true);
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => repo.markRead(any()));
      expect(await cubit.send('reply'), isTrue);
      await cubit.setStatus(SupportStatus.closed);
      verify(() => repo.setStatus('t', SupportStatus.closed)).called(1);
      await cubit.close();
    },
  );
  test('push supports validated support routes only', () {
    expect(
      PushRepositoryImpl.routeForData({
        'type': 'support_reply',
        'role': 'driver',
        'ticketId': 't',
      }),
      '/driver/support/t',
    );
    for (final payload in [
      {'type': 'support_reply', 'role': 'admin', 'ticketId': 't'},
      {'type': 'support_reply', 'role': 'rider', 'ticketId': '../bad'},
    ]) {
      expect(PushRepositoryImpl.routeForData(payload), isNull);
    }
  });
}
