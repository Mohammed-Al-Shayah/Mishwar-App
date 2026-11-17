import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/user/data/datasources/user_remote_data_source.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

// Firebase boundaries are mocked only in tests.
// ignore: subtype_of_sealed_class
class MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// Firebase boundaries are mocked only in tests.
// ignore: subtype_of_sealed_class
class MockDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// Firebase boundaries are mocked only in tests.
// ignore: subtype_of_sealed_class
class MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockFirestore firestore;
  late MockCollection collection;
  late MockDocument document;
  late MockSnapshot snapshot;
  late MockTransaction transaction;
  late UserRemoteDataSource source;
  setUpAll(() {
    registerFallbackValue(MockDocument());
    registerFallbackValue((Transaction _) async {});
  });
  setUp(() {
    firestore = MockFirestore();
    collection = MockCollection();
    document = MockDocument();
    snapshot = MockSnapshot();
    transaction = MockTransaction();
    source = UserRemoteDataSource(firestore);
    when(() => firestore.collection('users')).thenReturn(collection);
    when(() => collection.doc('u')).thenReturn(document);
    when(() => snapshot.id).thenReturn('u');
    when(() => transaction.get(document)).thenAnswer((_) async => snapshot);
    when(
      () => transaction.set(document, any<Map<String, dynamic>>()),
    ).thenReturn(transaction);
    when(() => firestore.runTransaction<void>(any())).thenAnswer((
      invocation,
    ) async {
      final handler =
          invocation.positionalArguments.first as TransactionHandler<void>;
      await handler(transaction);
    });
  });
  test(
    'creates owner profile with server timestamp, defaults and no role',
    () async {
      when(() => snapshot.exists).thenReturn(false);
      await source.createProfile(
        uid: 'u',
        phone: '+962791234567',
        name: 'Test User',
      );
      final written =
          verify(
                () => transaction.set(
                  document,
                  captureAny<Map<String, dynamic>>(),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(written['name'], 'Test User');
      expect(written['phone'], '+962791234567');
      expect(written.containsKey('rating'), isFalse);
      expect(written.containsKey('ratingCount'), isFalse);
      expect(written['createdAt'], isA<FieldValue>());
      expect(written.containsKey('role'), isFalse);
      expect(written.containsKey('id'), isFalse);
    },
  );
  test('repeated create cannot replace existing role or rating', () async {
    when(() => snapshot.exists).thenReturn(true);
    await source.createProfile(
      uid: 'u',
      phone: '+962791234567',
      name: 'Test User',
    );
    verifyNever(() => transaction.set(document, any<Map<String, dynamic>>()));
  });
  test('role update writes only rider or driver value', () async {
    when(() => document.update(any())).thenAnswer((_) async {});
    for (final role in UserRole.values) {
      await source.setRole('u', role);
      verify(() => document.update({'role': role.name})).called(1);
    }
  });
  test(
    'watches absent document and pending timestamp without decoding failure',
    () async {
      when(() => snapshot.exists).thenReturn(false);
      when(
        () => document.snapshots(),
      ).thenAnswer((_) => Stream.value(snapshot));
      expect(await source.watchUser('u').first, isNull);
      when(() => snapshot.exists).thenReturn(true);
      when(
        () => snapshot.data(),
      ).thenReturn({'name': 'Test', 'phone': 'p', 'createdAt': null});
      final model = await source.watchUser('u').first;
      expect(model!.id, 'u');
      expect(model.role, isNull);
      expect(
        model.createdAt,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    },
  );
}
