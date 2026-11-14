import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('wraps signed in and signed out events', () async {
    final repository = MockAuthRepository();
    const user = AuthUser(uid: 'uid', phone: '+12345678');
    when(
      repository.authStateChanges,
    ).thenAnswer((_) => Stream.fromIterable([null, user, null]));
    expect(await WatchAuthState(repository)(const NoParams()).toList(), [
      const Right<Failure, AuthUser?>(null),
      const Right<Failure, AuthUser?>(user),
      const Right<Failure, AuthUser?>(null),
    ]);
  });
}
