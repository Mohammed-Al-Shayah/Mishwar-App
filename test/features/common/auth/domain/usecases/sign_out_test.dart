import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/unregister_push_token.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUnregisterPushToken extends Mock implements UnregisterPushToken {}

void main() {
  test('delegates sign out', () async {
    final repository = MockAuthRepository();
    final unregister = MockUnregisterPushToken();
    when(
      () => unregister(const NoParams()),
    ).thenAnswer((_) async => const Right(unit));
    when(repository.signOut).thenAnswer((_) async => const Right(unit));
    expect(
      await SignOut(repository, unregister)(const NoParams()),
      const Right<dynamic, Unit>(unit),
    );
    verify(repository.signOut).called(1);
  });
  test('signs out even when push cleanup fails', () async {
    final repository = MockAuthRepository();
    final unregister = MockUnregisterPushToken();
    when(
      () => unregister(const NoParams()),
    ).thenAnswer((_) async => const Left(ServerFailure('push')));
    when(repository.signOut).thenAnswer((_) async => const Right(unit));
    expect(
      await SignOut(repository, unregister)(const NoParams()),
      const Right<dynamic, Unit>(unit),
    );
    verify(repository.signOut).called(1);
  });
}
