import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/exceptions.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/repositories/otp_protection_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-number guard, shared by initial sends and resends. No phone data stored.
@lazySingleton
class OtpProtectionStore implements OtpProtectionRepository {
  OtpProtectionStore(this._preferences);
  final SharedPreferences _preferences;
  String _key(String phone) =>
      'otp_protection_v1_${sha256.convert(utf8.encode(phone))}';
  Future<void> _queue = Future<void>.value();

  ({int count, int until}) _load(String phone) {
    final raw = _preferences.getString(_key(phone));
    if (raw == null) return (count: 0, until: 0);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (count: data['count'] as int, until: data['until'] as int);
  }

  OtpProtection _status(String phone) {
    final data = _load(phone);
    final remaining = ((data.until - clock.now().millisecondsSinceEpoch) / 1000)
        .ceil();
    return OtpProtection(
      remaining: remaining.clamp(0, 900),
      locked: data.count >= 5 && remaining > 0,
    );
  }

  @override
  Future<Either<Failure, OtpProtection>> read(String phone) async {
    try {
      return Right(_status(phone));
    } on Object {
      return const Left(ServerFailure('otp-protection-storage'));
    }
  }

  /// Reserve before contacting Auth; uncertain/failed sends count conservatively.
  Future<void> reserve(String phone) {
    final result = _queue.then((_) async {
      final status = _status(phone);
      if (status.remaining > 0) {
        throw const AuthException(
          'otp-send-limited',
          code: 'too-many-requests',
        );
      }
      final previous = _load(phone);
      final count = (previous.count >= 5 ? 0 : previous.count) + 1;
      final seconds = count >= 5
          ? 900
          : count == 1
          ? 60
          : count == 2
          ? 120
          : 300;
      final saved = await _preferences.setString(
        _key(phone),
        jsonEncode({
          'count': count,
          'until': clock.now().millisecondsSinceEpoch + seconds * 1000,
        }),
      );
      if (!saved) throw StateError('otp-protection-storage');
    });
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
