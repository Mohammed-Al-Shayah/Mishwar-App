import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart';
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('delegates sign out', () async {
    final repository = MockAuthRepository();
    when(repository.signOut).thenAnswer((_) async => const Right(unit));
    expect(
      await SignOut(repository)(const NoParams()),
      const Right<dynamic, Unit>(unit),
    );
    verify(repository.signOut).called(1);
  });
}
