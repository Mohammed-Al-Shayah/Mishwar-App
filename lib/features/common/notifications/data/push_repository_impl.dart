// The server sends to legacy FCM registration tokens via Admin Messaging.send.
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';

class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl(FirebaseMessaging? messaging, this._db) {
    if (messaging != null) _messaging = messaging;
  }
  // Never initialized or accessed on web.
  late final FirebaseMessaging _messaging;
  final FirebaseFirestore _db;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Exception {
      return const Left(ServerFailure('push'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() => _guard(() async {
    if (kIsWeb) return false;
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  });

  @override
  Future<Either<Failure, String?>> token() =>
      _guard(() async => kIsWeb ? null : _messaging.getToken());

  @override
  Stream<Either<Failure, String>> get onTokenRefresh async* {
    if (kIsWeb) return;
    try {
      await for (final token in _messaging.onTokenRefresh) {
        yield Right(token);
      }
    } on Exception {
      yield const Left(ServerFailure('push-refresh'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteToken() => _guard(() async {
    if (!kIsWeb) await _messaging.deleteToken();
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> saveToken(String uid, String token) =>
      _guard(() async {
        if (!kIsWeb) {
          await _db.doc('users/$uid').update({
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> removeToken(String uid) => _guard(() async {
    if (!kIsWeb) {
      await _db.doc('users/$uid').update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
    return unit;
  });

  static String? routeForData(Map<String, dynamic> data) {
    if (data['type'] == 'ride_offer') return '/driver';
    final role = data['role'];
    final id = data['ticketId'];
    if (data['type'] == 'support_reply' &&
        ['rider', 'driver'].contains(role) &&
        id is String &&
        RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(id)) {
      return '/$role/support/$id';
    }
    return null;
  }

  @override
  Stream<String> get openedRoutes {
    if (kIsWeb) return const Stream.empty();
    return FirebaseMessaging.onMessageOpenedApp
        .map((message) => routeForData(message.data))
        .where((route) => route != null)
        .cast<String>();
  }

  @override
  Future<Either<Failure, String?>> initialRoute() => _guard(() async {
    if (kIsWeb) return null;
    final message = await _messaging.getInitialMessage();
    return message == null ? null : routeForData(message.data);
  });
}
