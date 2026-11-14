import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/user/data/models/user_model.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

// Firestore snapshots are mocked only at the model boundary.
// ignore: subtype_of_sealed_class
class MockDocument extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  final date = DateTime.utc(2026);
  final json = <String, dynamic>{
    'id': 'u',
    'name': 'Name',
    'phone': '+962791234567',
    'role': 'driver',
    'photoUrl': null,
    'rating': 4.5,
    'ratingCount': 2,
    'fcmToken': 'token',
    'createdAt': Timestamp.fromDate(date),
  };
  test('round trip preserves stored fields and entity values', () {
    final model = UserModel.fromJson(json);
    expect(UserModel.fromJson({...model.toJson(), 'id': model.id}), model);
    expect(model.toJson().containsKey('id'), isFalse);
    expect(UserModel.fromEntity(model.toEntity()).toEntity(), model.toEntity());
    expect(model.toEntity().role, UserRole.driver);
    expect(model.toEntity().copyWith(role: null, photoUrl: 'url').role, isNull);
    expect(model.toEntity().copyWith(name: 'New').name, 'New');
  });
  test('unknown and absent roles remain unchosen; rating defaults', () {
    for (final role in ['admin', 'future', null]) {
      final model = UserModel.fromJson(
        {...json, 'role': role}..remove('rating'),
      );
      expect(model.role, isNull);
      expect(model.rating, 5);
    }
  });
  test('snapshot id overrides payload id', () {
    final snapshot = MockDocument();
    when(() => snapshot.id).thenReturn('actual');
    when(snapshot.data).thenReturn(json);
    expect(UserModel.fromFirestore(snapshot).id, 'actual');
  });
}
