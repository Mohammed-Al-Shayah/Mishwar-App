import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/account/domain/account_repository.dart';
import 'package:mishwar/features/common/account/domain/delete_account.dart';
import 'package:mishwar/features/common/account/domain/switch_role.dart';
import 'package:mishwar/features/common/account/domain/update_name.dart';
import 'package:mishwar/features/common/account/presentation/account_cubit.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class MockWatchUser extends Mock implements WatchUser {}

class MockWatchDriver extends Mock implements WatchDriver {}

class MockSignOut extends Mock implements SignOut {}

void main() {
  late MockAccountRepository repository;
  late MockWatchUser watchUser;
  late MockWatchDriver watchDriver;
  late MockSignOut signOut;
  late StreamController<Either<Failure, UserEntity?>> users;
  late StreamController<Either<Failure, DriverEntity?>> drivers;
  late AccountCubit cubit;
  final user = UserEntity(
    id: 'u',
    name: 'Test',
    phone: '+962790000000',
    createdAt: DateTime.utc(2026),
    role: UserRole.rider,
  );
  setUp(() {
    repository = MockAccountRepository();
    watchUser = MockWatchUser();
    watchDriver = MockWatchDriver();
    signOut = MockSignOut();
    users = StreamController.broadcast();
    drivers = StreamController.broadcast();
    when(() => watchUser('u')).thenAnswer((_) => users.stream);
    when(() => watchDriver('u')).thenAnswer((_) => drivers.stream);
    when(
      () => repository.updateName('u', any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => repository.switchRole(UserRole.driver),
    ).thenAnswer((_) async => const Right(unit));
    when(repository.deleteAccount).thenAnswer((_) async => const Right(unit));
    when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Right(unit));
    cubit = AccountCubit(
      watchUser,
      watchDriver,
      UpdateName(repository),
      SwitchRole(repository),
      DeleteAccount(repository),
      signOut,
    );
  });
  tearDown(() async {
    await cubit.close();
    await users.close();
    await drivers.close();
  });
  Future<void> start() async {
    await cubit.start('u');
    users.add(Right(user));
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'name is trimmed, 2-40 characters required, invalid names never write',
    () async {
      final update = UpdateName(repository);
      for (final name in ['', ' a ', 'x' * 41]) {
        expect((await update('u', name)).isLeft(), isTrue);
      }
      verifyNever(() => repository.updateName('u', any()));
      expect((await update('u', '  Test  ')).isRight(), isTrue);
      verify(() => repository.updateName('u', 'Test')).called(1);
    },
  );
  test(
    'watches user and driver only in driver mode and cancels on leaving',
    () async {
      await start();
      expect(cubit.state.user, user);
      verifyNever(() => watchDriver('u'));
      users.add(Right(user.copyWith(role: UserRole.driver)));
      await Future<void>.delayed(Duration.zero);
      const driver = DriverEntity(
        id: 'u',
        status: DriverStatus.approved,
        isOnline: false,
        vehicle: VehicleEntity(
          type: VehicleType.economy,
          make: 'Toyota',
          model: 'Corolla',
          color: 'White',
          plate: '12-34567',
        ),
      );
      drivers.add(const Right(driver));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.driver, driver);
      users.add(Right(user));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.driver, isNull);
      expect(drivers.hasListener, isFalse);
    },
  );
  test('actions invoke use cases and expose busy failure inline', () async {
    await start();
    expect(await cubit.updateName(' Updated '), isTrue);
    verify(() => repository.updateName('u', 'Updated')).called(1);
    when(
      () => repository.switchRole(UserRole.driver),
    ).thenAnswer((_) async => const Left(ServerFailure('account-busy')));
    expect(await cubit.switchRole(UserRole.driver), isFalse);
    expect(cubit.state.failure, const ServerFailure('account-busy'));
    expect(cubit.state.busy, isFalse);
    expect(await cubit.signOut(), isTrue);
    verify(() => signOut(const NoParams())).called(1);
  });
  test('deletion signs out only after successful server deletion', () async {
    await start();
    when(
      repository.deleteAccount,
    ).thenAnswer((_) async => const Left(ServerFailure('account-busy')));
    expect(await cubit.deleteAccount(), isFalse);
    verifyNever(() => signOut(const NoParams()));
    when(repository.deleteAccount).thenAnswer((_) async => const Right(unit));
    expect(await cubit.deleteAccount(), isTrue);
    verifyInOrder([repository.deleteAccount, () => signOut(const NoParams())]);
  });
  test(
    'duplicate submission is suppressed and completion after close is safe',
    () async {
      await start();
      final pending = Completer<Either<Failure, Unit>>();
      when(repository.deleteAccount).thenAnswer((_) => pending.future);
      final action = cubit.deleteAccount();
      expect(cubit.state.busy, isTrue);
      expect(await cubit.deleteAccount(), isFalse);
      await cubit.close();
      pending.complete(const Right(unit));
      expect(await action, isTrue);
    },
  );
}
