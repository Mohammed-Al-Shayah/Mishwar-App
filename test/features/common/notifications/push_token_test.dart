import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';
import 'package:mishwar/features/common/notifications/domain/push_token_sync.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/register_push_token.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/unregister_push_token.dart';
import 'package:mocktail/mocktail.dart';

class MockPush extends Mock implements PushRepository {}

class MockAuth extends Mock implements AuthRepository {}

void main() {
  late MockPush push;
  late MockAuth auth;
  late PushTokenSync sync;
  late RegisterPushToken register;
  late UnregisterPushToken unregister;
  late StreamController<AuthUser?> users;
  late StreamController<Either<Failure, String>> refresh;
  AuthUser? user;
  setUp(() {
    push = MockPush();
    auth = MockAuth();
    user = const AuthUser(uid: 'd');
    users = StreamController<AuthUser?>();
    refresh = StreamController<Either<Failure, String>>();
    when(() => auth.currentUser).thenAnswer((_) => user);
    when(auth.authStateChanges).thenAnswer((_) => users.stream);
    when(() => push.onTokenRefresh).thenAnswer((_) => refresh.stream);
    when(push.requestPermission).thenAnswer((_) async => const Right(true));
    when(push.token).thenAnswer((_) async => const Right('token'));
    when(
      () => push.saveToken(any(), any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => push.removeToken(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(push.deleteToken).thenAnswer((_) async => const Right(unit));
    when(auth.signOut).thenAnswer((_) async => const Right(unit));
    sync = PushTokenSync(push, auth)..start();
    register = RegisterPushToken(push, sync, auth);
    unregister = UnregisterPushToken(push, auth, sync);
  });
  tearDown(() async {
    await sync.dispose();
    await users.close();
    await refresh.close();
  });
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  test('registration permission then token then save', () async {
    expect(await register(const NoParams()), const Right<Failure, Unit>(unit));
    verifyInOrder([
      push.requestPermission,
      push.token,
      () => push.saveToken('d', 'token'),
    ]);
  });
  test('permission denied is silent and skips token', () async {
    when(push.requestPermission).thenAnswer((_) async => const Right(false));
    expect(await register(const NoParams()), const Right<Failure, Unit>(unit));
    verifyNever(push.token);
  });
  test('missing token and signed-out registration do nothing', () async {
    when(push.token).thenAnswer((_) async => const Right(null));
    await register(const NoParams());
    verifyNever(() => push.saveToken(any(), any()));
    user = null;
    clearInteractions(push);
    await register(const NoParams());
    verifyNever(push.requestPermission);
  });
  test('registration failures propagate', () async {
    when(
      push.requestPermission,
    ).thenAnswer((_) async => const Left(ServerFailure('permission')));
    expect((await register(const NoParams())).isLeft(), isTrue);
    when(push.requestPermission).thenAnswer((_) async => const Right(true));
    when(
      push.token,
    ).thenAnswer((_) async => const Left(ServerFailure('token')));
    expect((await register(const NoParams())).isLeft(), isTrue);
  });
  test(
    'refresh sync starts once, skips signed-out, follows new session',
    () async {
      sync.start();
      refresh.add(const Right('new'));
      await flush();
      verify(() => push.saveToken('d', 'new')).called(1);
      user = null;
      users.add(null);
      await flush();
      refresh.add(const Right('ignored'));
      await flush();
      verifyNever(() => push.saveToken(any(), 'ignored'));
      user = const AuthUser(uid: 'other');
      users.add(user);
      await flush();
      refresh
        ..add(const Left(ServerFailure('stream')))
        ..add(const Right('other-token'));
      await flush();
      verify(() => push.saveToken('other', 'other-token')).called(1);
    },
  );
  test(
    'unregister drains pending write and ignores later refresh before signout',
    () async {
      final pending = Completer<Either<Failure, Unit>>();
      when(
        () => push.saveToken('d', 'in-flight'),
      ).thenAnswer((_) => pending.future);
      refresh.add(const Right('in-flight'));
      await flush();
      final signingOut = SignOut(auth, unregister)(const NoParams());
      await flush();
      verifyNever(() => push.removeToken('d'));
      refresh.add(const Right('late'));
      await flush();
      pending.complete(const Right(unit));
      await signingOut;
      verifyInOrder([
        () => push.removeToken('d'),
        push.deleteToken,
        auth.signOut,
      ]);
      verifyNever(() => push.saveToken(any(), 'late'));
    },
  );
  test(
    'registration returning after unregister cannot restore token',
    () async {
      final permission = Completer<Either<Failure, bool>>();
      when(push.requestPermission).thenAnswer((_) => permission.future);
      final pending = register(const NoParams());
      await unregister(const NoParams());
      permission.complete(const Right(true));
      await pending;
      verifyNever(() => push.saveToken(any(), any()));
    },
  );
  test(
    // The SDK token is still deleted, so a token left on the old profile is
    // invalid and the server removes it on its next send.
    'cleanup failure still deletes SDK token and does not block signout',
    () async {
      when(
        () => push.removeToken('d'),
      ).thenAnswer((_) async => const Left(ServerFailure('remove')));
      expect(
        (await SignOut(auth, unregister)(const NoParams())).isRight(),
        isTrue,
      );
      verify(push.deleteToken).called(1);
      verify(auth.signOut).called(1);
    },
  );
  test('signed-out unregister still deletes SDK token', () async {
    user = null;
    await unregister(const NoParams());
    verifyNever(() => push.removeToken(any()));
    verify(push.deleteToken).called(1);
  });
}
