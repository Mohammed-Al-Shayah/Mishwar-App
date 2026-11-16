// Tests the legacy registration-token contract used by Admin Messaging.send.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/notifications/data/push_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockMessaging extends Mock implements FirebaseMessaging {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockSettings extends Mock implements NotificationSettings {}

// Mock Firebase boundary only.
// ignore: subtype_of_sealed_class
class MockDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockMessaging messaging;
  late MockDocument document;
  late PushRepositoryImpl repository;
  setUp(() {
    messaging = MockMessaging();
    final db = MockFirestore();
    document = MockDocument();
    when(() => db.doc('users/d')).thenReturn(document);
    when(() => document.update(any())).thenAnswer((_) async {});
    repository = PushRepositoryImpl(messaging, db);
  });
  for (final status in AuthorizationStatus.values) {
    test('maps permission $status', () async {
      final settings = MockSettings();
      when(() => settings.authorizationStatus).thenReturn(status);
      when(
        () => messaging.requestPermission(),
      ).thenAnswer((_) async => settings);
      expect(
        await repository.requestPermission(),
        Right<Failure, bool>(
          status == AuthorizationStatus.authorized ||
              status == AuthorizationStatus.provisional,
        ),
      );
    });
  }
  test('maps token and deletion', () async {
    when(messaging.getToken).thenAnswer((_) async => 'token');
    when(messaging.deleteToken).thenAnswer((_) async {});
    expect(await repository.token(), const Right<Failure, String?>('token'));
    expect(await repository.deleteToken(), const Right<Failure, Unit>(unit));
    verify(messaging.deleteToken).called(1);
  });
  test('writes token and removal with server timestamps', () async {
    await repository.saveToken('d', 'token');
    verify(
      () => document.update({
        'fcmToken': 'token',
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }),
    ).called(1);
    await repository.removeToken('d');
    verify(
      () => document.update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }),
    ).called(1);
  });
  test('Firebase exceptions map to failures', () async {
    when(
      messaging.getToken,
    ).thenThrow(FirebaseException(plugin: 'messaging', code: 'network'));
    when(messaging.deleteToken).thenThrow(Exception('failed'));
    when(() => messaging.requestPermission()).thenThrow(Exception('failed'));
    when(() => document.update(any())).thenThrow(Exception('failed'));
    expect((await repository.token()).isLeft(), isTrue);
    expect((await repository.deleteToken()).isLeft(), isTrue);
    expect((await repository.requestPermission()).isLeft(), isTrue);
    expect((await repository.saveToken('d', 'token')).isLeft(), isTrue);
    expect((await repository.removeToken('d')).isLeft(), isTrue);
  });
  test('refresh tokens and stream errors map to Either', () async {
    final stream = StreamController<String>();
    when(() => messaging.onTokenRefresh).thenAnswer((_) => stream.stream);
    final values = repository.onTokenRefresh.toList();
    stream
      ..add('new')
      ..addError(Exception('failed'));
    await stream.close();
    expect(await values, [
      const Right<Failure, String>('new'),
      const Left<Failure, String>(ServerFailure('push-refresh')),
    ]);
  });
  test('initial message maps only ride_offer type', () async {
    when(messaging.getInitialMessage).thenAnswer(
      (_) async => const RemoteMessage(
        data: {'type': 'ride_offer', 'rideId': '../../fake', 'route': '/admin'},
      ),
    );
    expect(
      await repository.initialRoute(),
      const Right<Failure, String?>('/driver'),
    );
    when(messaging.getInitialMessage).thenAnswer((_) async => null);
    expect(
      await repository.initialRoute(),
      const Right<Failure, String?>(null),
    );
    expect(
      PushRepositoryImpl.routeForData({'type': 'other', 'route': '/driver'}),
      isNull,
    );
    when(messaging.getInitialMessage).thenThrow(Exception('failed'));
    expect((await repository.initialRoute()).isLeft(), isTrue);
  });
}
