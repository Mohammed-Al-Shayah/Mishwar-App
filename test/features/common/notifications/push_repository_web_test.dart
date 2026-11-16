import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/notifications/data/push_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  test('web skips messaging and token persistence entirely', () async {
    final db = MockFirestore();
    final repository = PushRepositoryImpl(null, db);
    expect(
      await repository.requestPermission(),
      const Right<Failure, bool>(false),
    );
    expect(await repository.token(), const Right<Failure, String?>(null));
    expect(await repository.deleteToken(), const Right<Failure, Unit>(unit));
    expect(
      await repository.saveToken('u', 'token'),
      const Right<Failure, Unit>(unit),
    );
    expect(await repository.removeToken('u'), const Right<Failure, Unit>(unit));
    expect(await repository.onTokenRefresh.toList(), isEmpty);
    expect(await repository.openedRoutes.toList(), isEmpty);
    expect(
      await repository.initialRoute(),
      const Right<Failure, String?>(null),
    );
    verifyZeroInteractions(db);
  }, skip: !kIsWeb);
}
