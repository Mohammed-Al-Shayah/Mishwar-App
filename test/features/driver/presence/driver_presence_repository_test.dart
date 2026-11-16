import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/geo/geohash.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/driver/presence/data/driver_presence_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

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

void main() {
  late MockFirestore firestore;
  late MockAuth auth;
  late MockDocument document;
  late DriverPresenceRepositoryImpl repository;
  setUp(() {
    firestore = MockFirestore();
    auth = MockAuth();
    document = MockDocument();
    final collection = MockCollection();
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('driver');
    when(() => firestore.collection('drivers')).thenReturn(collection);
    when(() => collection.doc('driver')).thenReturn(document);
    when(() => document.update(any())).thenAnswer((_) async {});
    final snapshot = MockSnapshot();
    when(document.get).thenAnswer((_) async => snapshot);
    when(snapshot.data).thenReturn({
      'location': {
        'geopoint': const GeoPoint(31.9539, 35.9106),
        'geohash': 'sv9tc1',
      },
      'heading': 90.0,
    });
    repository = DriverPresenceRepositoryImpl(firestore, auth);
  });
  const point = GeoPointValue(31.9539, 35.9106);
  test(
    'online and updates use update, precision 9 and server timestamp only',
    () async {
      for (final action in [repository.goOnline, repository.updateLocation]) {
        expect(
          await action(point, heading: 123),
          const Right<Failure, Unit>(unit),
        );
        final data =
            verify(() => document.update(captureAny())).captured.single
                as Map<Object, Object?>;
        expect(data, {
          'isOnline': true,
          'location': {
            'geohash': encodeGeohash(point.lat, point.lng),
            'geopoint': const GeoPoint(31.9539, 35.9106),
          },
          'heading': 123.0,
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
        expect(
          (data['location']! as Map<Object, Object?>)['geohash'],
          hasLength(9),
        );
      }
    },
  );
  test('offline merges only isOnline and server timestamp', () async {
    await repository.goOffline();
    verify(
      () => document.update({
        'isOnline': false,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }),
    ).called(1);
    verifyNever(document.get);
  });
  test('unknown heading omitted rather than writing null', () async {
    await repository.goOnline(point);
    final data =
        verify(() => document.update(captureAny())).captured.single
            as Map<Object, Object?>;
    expect(data.containsKey('heading'), isFalse);
  });
  test('permission denied maps to PermissionFailure', () async {
    when(() => document.update(any())).thenThrow(
      FirebaseException(plugin: 'firestore', code: 'permission-denied'),
    );
    expect(
      (await repository.goOnline(point)).getLeft().toNullable(),
      isA<PermissionFailure>(),
    );
  });
  test('signed out does not write', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect((await repository.goOffline()).isLeft(), isTrue);
    verifyNever(() => document.update(any()));
  });
  test(
    'trip location writes only the live channel and server timestamp',
    () async {
      when(() => firestore.doc('rides/ride/live/driver')).thenReturn(document);
      when(() => document.set(any())).thenAnswer((_) async {});
      expect(
        await repository.publishTripLocation('ride', point, heading: 90),
        const Right<dynamic, dynamic>(unit),
      );
      final data =
          verify(() => document.set(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(data, {
        'geopoint': const GeoPoint(31.9539, 35.9106),
        'heading': 90.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      when(() => document.set(any())).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );
      expect(
        (await repository.publishTripLocation('ride', point)).isLeft(),
        isTrue,
      );
    },
  );
}
