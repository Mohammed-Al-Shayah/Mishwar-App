import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart';
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  setUp(() {
    repository = MockUserRepository();
  });
  for (final length in [0, 1, 41]) {
    test('rejects name with $length characters', () async {
      final result = await CreateUserProfile(repository)(
        uid: 'u',
        phone: 'p',
        name: 'a' * length,
      );
      expect(
        result,
        const Left<Failure, Unit>(ValidationFailure('name-length')),
      );
      verifyZeroInteractions(repository);
    });
  }
  for (final length in [2, 40]) {
    test('trims valid name at boundary $length', () async {
      final name = 'a' * length;
      when(
        () => repository.createProfile(uid: 'u', phone: 'p', name: name),
      ).thenAnswer((_) async => const Right(unit));
      expect(
        await CreateUserProfile(repository)(
          uid: 'u',
          phone: 'p',
          name: ' $name ',
        ),
        const Right<Failure, Unit>(unit),
      );
      verify(
        () => repository.createProfile(uid: 'u', phone: 'p', name: name),
      ).called(1);
    });
  }
  test('watch and role delegate without replacing failures', () async {
    when(
      () => repository.watchUser('u'),
    ).thenAnswer((_) => Stream.value(const Right(null)));
    expect(
      await WatchUser(repository)('u').first,
      const Right<Failure, UserEntity?>(null),
    );
    when(
      () => repository.setRole('u', UserRole.rider),
    ).thenAnswer((_) async => const Left(ServerFailure('permission-denied')));
    expect(
      await SetUserRole(repository)('u', UserRole.rider),
      const Left<Failure, Unit>(ServerFailure('permission-denied')),
    );
  });
}
