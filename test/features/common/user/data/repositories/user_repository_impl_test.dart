import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/data/datasources/user_remote_data_source.dart';
import 'package:mishwar/features/common/user/data/models/user_model.dart';
import 'package:mishwar/features/common/user/data/repositories/user_repository_impl.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockSource extends Mock implements UserRemoteDataSource {}

void main() {
  late MockSource source;
  late UserRepositoryImpl repository;
  setUp(() {
    source = MockSource();
    repository = UserRepositoryImpl(source);
  });
  for (final code in ['unavailable', 'permission-denied']) {
    test('maps $code for stream and both writes', () async {
      final exception = FirebaseException(
        plugin: 'cloud_firestore',
        code: code,
      );
      final failure = code == 'unavailable'
          ? const NetworkFailure('unavailable')
          : ServerFailure(code);
      when(
        () => source.watchUser('u'),
      ).thenAnswer((_) => Stream.error(exception));
      when(
        () => source.createProfile(uid: 'u', phone: 'p', name: 'Test'),
      ).thenThrow(exception);
      when(() => source.setRole('u', UserRole.rider)).thenThrow(exception);
      expect(
        await repository.watchUser('u').first,
        Left<Failure, UserEntity?>(failure),
      );
      expect(
        await repository.createProfile(uid: 'u', phone: 'p', name: 'Test'),
        Left<Failure, Unit>(failure),
      );
      expect(
        await repository.setRole('u', UserRole.rider),
        Left<Failure, Unit>(failure),
      );
    });
  }
  test('maps models and absent profiles', () async {
    final model = UserModel(
      id: 'u',
      name: 'Test',
      phone: 'p',
      createdAt: DateTime.utc(2026),
    );
    when(
      () => source.watchUser('u'),
    ).thenAnswer((_) => Stream.fromIterable([null, model]));
    expect(await repository.watchUser('u').toList(), [
      const Right<Failure, UserEntity?>(null),
      Right<Failure, UserEntity?>(model.toEntity()),
    ]);
  });
  test('successful writes return unit', () async {
    when(
      () => source.createProfile(uid: 'u', phone: 'p', name: 'Test'),
    ).thenAnswer((_) async {});
    when(() => source.setRole('u', UserRole.driver)).thenAnswer((_) async {});
    expect(
      await repository.createProfile(uid: 'u', phone: 'p', name: 'Test'),
      const Right<Failure, Unit>(unit),
    );
    expect(
      await repository.setRole('u', UserRole.driver),
      const Right<Failure, Unit>(unit),
    );
  });
}
