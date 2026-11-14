import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchDriver extends Mock implements WatchDriver {}

class MockWatchAuth extends Mock implements WatchAuthState {}

class MockWatchUser extends Mock implements WatchUser {}

void main() {
  late StreamController<Either<Failure, DriverEntity?>> driverStream;
  const pendingDriver = DriverEntity(
    id: 'u',
    status: DriverStatus.pending,
    isOnline: false,
    vehicle: VehicleEntity(
      type: VehicleType.economy,
      make: 'Toyota',
      model: 'Corolla',
      color: 'White',
      plate: '12-34567',
    ),
  );
  late MockWatchDriver drivers;
  late MockWatchAuth auth;
  late MockWatchUser users;
  late StreamController<Either<Failure, AuthUser?>> authStream;
  late StreamController<Either<Failure, UserEntity?>> profileStream;
  const user = AuthUser(uid: 'u', phone: '+962791234567');
  final profile = UserEntity(
    id: 'u',
    name: 'Test User',
    phone: user.phone!,
    createdAt: DateTime.utc(2026),
  );
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  setUp(() {
    driverStream = StreamController.broadcast();
    drivers = MockWatchDriver();
    when(() => drivers('u')).thenAnswer((_) => Stream.value(const Right(null)));
    auth = MockWatchAuth();
    users = MockWatchUser();
    authStream = StreamController.broadcast();
    profileStream = StreamController.broadcast();
    when(() => auth(const NoParams())).thenAnswer((_) => authStream.stream);
    when(() => users('u')).thenAnswer((_) => profileStream.stream);
  });
  tearDown(() async {
    await driverStream.close();
    await authStream.close();
    await profileStream.close();
  });
  blocTest<SessionCubit, SessionState>(
    'signed out, name, role, ready, signed out',
    build: () => SessionCubit(auth, users, drivers),
    act: (cubit) async {
      expect(cubit.state, const SessionUnknown());
      authStream.add(const Right(null));
      await flush();
      authStream.add(const Right(user));
      await flush();
      profileStream.add(const Right(null));
      await flush();
      profileStream.add(Right(profile));
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.rider)));
      await flush();
      authStream.add(const Right(null));
      await flush();
    },
    expect: () => [
      const SessionSignedOut(),
      const SessionUnknown(),
      const SessionNeedsName(user),
      SessionNeedsRole(profile),
      SessionReady(profile.copyWith(role: UserRole.rider)),
      const SessionSignedOut(),
    ],
  );
  blocTest<SessionCubit, SessionState>(
    'profile failure retries and resolves driver',
    build: () => SessionCubit(auth, users, drivers),
    act: (cubit) async {
      authStream.add(const Right(user));
      await flush();
      profileStream.add(const Left(NetworkFailure('unavailable')));
      await flush();
      cubit.retry();
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.driver)));
      await flush();
    },
    expect: () => [
      const SessionError(NetworkFailure('unavailable')),
      const SessionUnknown(),
      SessionReady(profile.copyWith(role: UserRole.driver)),
    ],
    verify: (_) => verify(() => users('u')).called(2),
  );
  blocTest<SessionCubit, SessionState>(
    'late profile events cannot restore a signed-out user',
    build: () => SessionCubit(auth, users, drivers),
    act: (_) async {
      authStream.add(const Right(user));
      await flush();
      authStream.add(const Right(null));
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.rider)));
      await flush();
    },
    expect: () => [const SessionSignedOut()],
  );
  blocTest<SessionCubit, SessionState>(
    'auth failure retries authentication',
    build: () => SessionCubit(auth, users, drivers),
    act: (cubit) async {
      authStream.add(const Left(UnexpectedFailure('auth')));
      await flush();
      cubit.retry();
      await flush();
      authStream.add(const Right(null));
      await flush();
    },
    expect: () => [
      const SessionError(UnexpectedFailure('auth')),
      const SessionUnknown(),
      const SessionSignedOut(),
    ],
  );
  blocTest<SessionCubit, SessionState>(
    'watches driver snapshots and cancels on sign out',
    build: () {
      when(() => drivers('u')).thenAnswer((_) => driverStream.stream);
      return SessionCubit(auth, users, drivers);
    },
    act: (cubit) async {
      authStream.add(const Right(user));
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.driver)));
      await flush();
      expect(cubit.state, const SessionUnknown());
      driverStream.add(const Right(null));
      await flush();
      driverStream.add(const Right(pendingDriver));
      await flush();
      authStream.add(const Right(null));
      await flush();
      expect(driverStream.hasListener, false);
      driverStream.add(const Right(pendingDriver));
      await flush();
    },
    expect: () => [
      SessionReady(profile.copyWith(role: UserRole.driver)),
      SessionReady(
        profile.copyWith(role: UserRole.driver),
        driver: pendingDriver,
      ),
      const SessionSignedOut(),
    ],
    verify: (_) => verify(() => drivers('u')).called(1),
  );
  blocTest<SessionCubit, SessionState>(
    'driver watch failure surfaces and retry reattaches',
    build: () {
      when(() => drivers('u')).thenAnswer((_) => driverStream.stream);
      return SessionCubit(auth, users, drivers);
    },
    act: (cubit) async {
      authStream.add(const Right(user));
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.driver)));
      await flush();
      driverStream.add(const Left(NetworkFailure('offline')));
      await flush();
      cubit.retry();
      await flush();
      profileStream.add(Right(profile.copyWith(role: UserRole.driver)));
      await flush();
      driverStream.add(const Right(pendingDriver));
      await flush();
    },
    expect: () => [
      const SessionError(NetworkFailure('offline')),
      const SessionUnknown(),
      SessionReady(
        profile.copyWith(role: UserRole.driver),
        driver: pendingDriver,
      ),
    ],
    verify: (_) => verify(() => drivers('u')).called(2),
  );
  test('closing cancels both subscriptions', () async {
    final cubit = SessionCubit(auth, users, drivers);
    authStream.add(const Right(user));
    await flush();
    expect(profileStream.hasListener, isTrue);
    await cubit.close();
    expect(authStream.hasListener, isFalse);
    expect(profileStream.hasListener, isFalse);
  });
}
