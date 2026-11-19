import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/exceptions.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';

abstract interface class AuthRemoteDataSource {
  Future<OtpSession> sendOtp(String phoneE164, {OtpSession? resendFrom});
  Future<AuthUser> verifyOtp(OtpSession session, String code);
  AuthUser? autoVerifiedUser(OtpSession session);
  Future<void> signOut();
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth);
  final FirebaseAuth _auth;
  final _webConfirmations = <OtpSession, ConfirmationResult>{};
  final _autoVerified = <OtpSession, AuthUser>{};
  final _createdAt = <OtpSession, DateTime>{};
  final _wrongCodes = <OtpSession, int>{};
  int _generation = 0;
  static const _timeout = Duration(seconds: 60);
  static const _sessionLifetime = Duration(minutes: 10);

  AuthException _exception(FirebaseAuthException error) =>
      AuthException(error.message ?? error.code, code: error.code);
  AuthUser _user(User? user) {
    if (user == null) throw const AuthException('missing-auth-user');
    return AuthUser(uid: user.uid, phone: user.phoneNumber);
  }

  void _forget(OtpSession session) {
    _webConfirmations.remove(session);
    _autoVerified.remove(session);
    _createdAt.remove(session);
    _wrongCodes.remove(session);
  }

  void _remember(OtpSession session) {
    final now = DateTime.now();
    for (final entry in _createdAt.entries.toList()) {
      if (now.difference(entry.value) >= _sessionLifetime) _forget(entry.key);
    }
    // Bound outstanding handles even if a caller abandons attempts.
    if (_createdAt.length >= 20) _forget(_createdAt.keys.first);
    _createdAt[session] = now;
  }

  @override
  Future<OtpSession> sendOtp(String phoneE164, {OtpSession? resendFrom}) async {
    _generation++;
    _autoVerified.clear();
    try {
      if (kIsWeb) {
        final generation = _generation;
        final confirmation = await _auth.signInWithPhoneNumber(phoneE164);
        if (generation != _generation) {
          throw const AuthException('session-expired', code: 'session-expired');
        }
        final session = OtpSession(phone: phoneE164);
        _remember(session);
        _webConfirmations[session] = confirmation;
        if (resendFrom != null) _forget(resendFrom);
        return session;
      }
      return await _sendMobile(phoneE164, resendFrom);
    } on FirebaseAuthException catch (error) {
      throw _exception(error);
    }
  }

  Future<OtpSession> _sendMobile(String phone, OtpSession? resendFrom) async {
    final completer = Completer<OtpSession>();
    final generation = _generation;
    OtpSession? sentSession;
    var active = true;
    bool isActive() => active && generation == _generation;
    void fail(Object error, [StackTrace? stack]) {
      if (!completer.isCompleted) completer.completeError(error, stack);
    }

    final timer = Timer(_timeout, () {
      active = false;
      fail(const AuthException('otp-request-timeout', code: 'session-expired'));
    });
    Future<void> request() async {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          forceResendingToken: resendFrom?.phone == phone
              ? resendFrom?.resendToken
              : null,
          timeout: _timeout,
          verificationCompleted: (credential) async {
            if (!isActive()) return;
            try {
              final result = await _auth.signInWithCredential(credential);
              if (!isActive()) return;
              final user = _user(result.user);
              final session =
                  sentSession ?? OtpSession(phone: phone, autoVerified: true);
              _remember(session);
              _autoVerified[session] = user;
              active = false;
              timer.cancel();
              if (!completer.isCompleted) completer.complete(session);
            } on FirebaseAuthException catch (error, stack) {
              fail(_exception(error), stack);
            } on Object catch (error, stack) {
              fail(error, stack);
            }
          },
          verificationFailed: (error) {
            if (!isActive()) return;
            active = false;
            timer.cancel();
            fail(_exception(error));
          },
          codeSent: (verificationId, resendToken) {
            if (!isActive() || completer.isCompleted) return;
            final session = OtpSession(
              phone: phone,
              verificationId: verificationId,
              resendToken: resendToken,
            );
            _remember(session);
            sentSession = session;
            if (resendFrom != null) _forget(resendFrom);
            completer.complete(session);
          },
          codeAutoRetrievalTimeout: (_) {
            // Manual OTP entry remains valid after auto-retrieval stops.
          },
        );
      } on FirebaseAuthException catch (error, stack) {
        active = false;
        timer.cancel();
        fail(_exception(error), stack);
      } on Object catch (error, stack) {
        active = false;
        timer.cancel();
        fail(error, stack);
      }
    }

    unawaited(request());
    return completer.future;
  }

  @override
  AuthUser? autoVerifiedUser(OtpSession session) {
    final created = _createdAt[session];
    if (created != null &&
        DateTime.now().difference(created) >= _sessionLifetime) {
      _forget(session);
      return null;
    }
    return _autoVerified[session];
  }

  @override
  Future<AuthUser> verifyOtp(OtpSession session, String code) async {
    try {
      if ((_wrongCodes[session] ?? 0) >= 5) {
        throw const AuthException('session-expired', code: 'session-expired');
      }
      final automatic = autoVerifiedUser(session);
      if (automatic != null) return automatic;
      UserCredential result;
      if (kIsWeb) {
        final confirmation = _webConfirmations[session];
        final created = _createdAt[session];
        if (confirmation == null ||
            created == null ||
            DateTime.now().difference(created) >= _sessionLifetime) {
          _forget(session);
          throw const AuthException('session-expired', code: 'session-expired');
        }
        result = await confirmation.confirm(code);
      } else {
        final id = session.verificationId;
        if (id == null) {
          throw const AuthException('session-expired', code: 'session-expired');
        }
        result = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: id, smsCode: code),
        );
      }
      final user = _user(result.user);
      _forget(session);
      return user;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-verification-code') {
        _wrongCodes[session] = (_wrongCodes[session] ?? 0) + 1;
      }
      throw _exception(error);
    }
  }

  @override
  Future<void> signOut() async {
    _generation++;
    _webConfirmations.clear();
    _autoVerified.clear();
    _createdAt.clear();
    _wrongCodes.clear();
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw _exception(error);
    }
  }

  @override
  AuthUser? get currentUser {
    try {
      final user = _auth.currentUser;
      return user == null ? null : _user(user);
    } on FirebaseAuthException catch (error) {
      throw _exception(error);
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    try {
      await for (final user
          in kIsWeb ? _auth.idTokenChanges() : _auth.authStateChanges()) {
        if (user == null) {
          yield null;
        } else if (kIsWeb) {
          final token = await user.getIdTokenResult();
          yield AuthUser(
            uid: user.uid,
            phone: user.phoneNumber,
            isAdmin: token.claims?['admin'] == true,
          );
        } else {
          yield _user(user);
        }
      }
    } on FirebaseAuthException catch (error) {
      throw _exception(error);
    }
  }
}
