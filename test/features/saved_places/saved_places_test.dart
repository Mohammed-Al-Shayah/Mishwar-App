import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/saved_places/data/saved_place_model.dart';
import 'package:mishwar/features/common/saved_places/data/saved_places_remote_data_source.dart';
import 'package:mishwar/features/common/saved_places/data/saved_places_repository_impl.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_places_repository.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_places_usecases.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/saved_places_mocks.dart';
import '../history/history_data_cubit_test.dart'
    show MockCollection, MockDb, MockDoc, MockQuery, MockQuerySnapshot, MockRef;

class MockSource extends Mock implements SavedPlacesRemoteDataSource {}

class MockRepository extends Mock implements SavedPlacesRepository {}

SavedPlace other(String id, {String name = 'Park'}) => SavedPlace(
  id: id,
  label: SavedPlaceLabel.other,
  name: name,
  address: savedOther.address,
  location: savedOther.location,
);

void main() {
  setUpAll(() => registerFallbackValue(savedHome));
  test(
    'repository maps Firestore models, orders labels, and maps stream failures',
    () async {
      final source = MockSource();
      final model = SavedPlaceModel.fromJson({
        'id': 'home',
        'label': 'home',
        'name': 'My house',
        'address': 'Home street',
        'geopoint': const GeoPoint(31, 35),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026)),
      });
      expect(model.toEntity().location, savedHome.location);
      expect(model.toEntity().updatedAt, DateTime.utc(2026));
      final stream = StreamController<List<SavedPlaceModel>>();
      when(() => source.watch('u')).thenAnswer((_) => stream.stream);
      final results = SavedPlacesRepositoryImpl(source).watch('u').toList();
      stream
        ..add([
          SavedPlaceModel(
            id: 'other',
            label: SavedPlaceLabel.other,
            name: 'Park',
            address: '',
            geopoint: savedOther.location,
          ),
          model,
        ])
        ..addError(Exception('offline'));
      await stream.close();
      final values = await results;
      expect(values.first.getOrElse((_) => []).map((p) => p.id), [
        'home',
        'other',
      ]);
      expect(
        values.last,
        const Left<Failure, List<SavedPlace>>(ServerFailure('saved-places')),
      );
    },
  );
  test('repository maps writes, server failures, and the remote cap', () async {
    final source = MockSource();
    final repo = SavedPlacesRepositoryImpl(source);
    when(() => source.upsert('u', savedHome)).thenAnswer((_) async {});
    when(() => source.rename('u', 'home', 'New')).thenAnswer((_) async {});
    when(() => source.delete('u', 'home')).thenThrow(Exception('offline'));
    when(
      () => source.addOther('u', savedOther),
    ).thenThrow(const SavedPlacesLimitException());
    expect(await repo.upsert('u', savedHome), const Right<Failure, Unit>(unit));
    expect(
      await repo.rename('u', 'home', 'New'),
      const Right<Failure, Unit>(unit),
    );
    expect(
      await repo.delete('u', 'home'),
      const Left<Failure, Unit>(ServerFailure('saved-places')),
    );
    expect(
      await repo.addOther('u', savedOther),
      const Left<Failure, Unit>(ValidationFailure('saved-places-limit')),
    );
  });
  test('use cases validate input and delegate all operations', () async {
    final repo = MockRepository();
    when(
      () => repo.watch('u'),
    ).thenAnswer((_) => Stream.value(const Right([savedHome])));
    when(
      () => repo.upsert('u', savedHome),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => repo.addOther('u', savedOther),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => repo.rename('u', 'home', 'New'),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => repo.delete('u', 'home'),
    ).thenAnswer((_) async => const Right(unit));
    expect((await WatchSavedPlaces(repo)('u').first).isRight(), isTrue);
    expect((await UpsertSavedPlace(repo)('u', savedHome)).isRight(), isTrue);
    expect((await AddOtherSavedPlace(repo)('u', savedOther)).isRight(), isTrue);
    expect(
      (await RenameSavedPlace(repo)('u', 'home', ' New ')).isRight(),
      isTrue,
    );
    expect((await DeleteSavedPlace(repo)('u', 'home')).isRight(), isTrue);
    for (final name in ['', 'x' * 41]) {
      expect(
        (await AddOtherSavedPlace(repo)('u', other('', name: name))).isLeft(),
        isTrue,
      );
      expect(
        (await RenameSavedPlace(repo)('u', 'home', name)).isLeft(),
        isTrue,
      );
    }
    expect((await UpsertSavedPlace(repo)('u', other(''))).isLeft(), isTrue);
    expect((await AddOtherSavedPlace(repo)('u', savedHome)).isLeft(), isTrue);
  });
  test(
    'cubit list, singleton, add, rename, delete, failures and cap',
    () async {
      final repo = MockRepository();
      final stream = StreamController<Either<Failure, List<SavedPlace>>>();
      when(() => repo.watch('u')).thenAnswer((_) => stream.stream);
      when(
        () => repo.upsert('u', savedHome),
      ).thenAnswer((_) async => const Right(unit));
      final added = other('');
      when(
        () => repo.addOther('u', added),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repo.rename('u', 'home', 'New'),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repo.delete('u', 'home'),
      ).thenAnswer((_) async => const Left(ServerFailure('offline')));
      final cubit = SavedPlacesCubit(
        WatchSavedPlaces(repo),
        UpsertSavedPlace(repo),
        AddOtherSavedPlace(repo),
        RenameSavedPlace(repo),
        DeleteSavedPlace(repo),
      );
      await cubit.start('u');
      stream.add(const Right([savedHome]));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.places, [savedHome]);
      expect(await cubit.save(savedHome), isTrue);
      expect(await cubit.save(added), isTrue);
      expect(await cubit.rename('home', 'New'), isTrue);
      expect(await cubit.delete('home'), isFalse);
      expect(cubit.state.failure, const ServerFailure('offline'));
      when(
        () => repo.delete('u', 'home'),
      ).thenAnswer((_) async => const Right(unit));
      expect(await cubit.delete('home'), isTrue);
      stream.add(Right(List.generate(20, (i) => other('$i'))));
      await Future<void>.delayed(Duration.zero);
      expect(await cubit.save(added), isFalse);
      expect(
        cubit.state.failure,
        const ValidationFailure('saved-places-limit'),
      );
      verify(() => repo.addOther('u', added)).called(1);
      stream.add(const Left(ServerFailure('watch')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.failure, const ServerFailure('watch'));
      expect(cubit.state.places, hasLength(20));
      await cubit.close();
      await stream.close();
    },
  );
  test(
    'remote cap and fixed singleton ids',
    () async {
      final db = MockDb();
      final users = MockCollection();
      final user = MockRef();
      final places = MockCollection();
      final home = MockRef();
      final query = MockQuery();
      final snapshot = MockQuerySnapshot();
      when(() => db.collection('users')).thenReturn(users);
      when(() => users.doc('u')).thenReturn(user);
      when(() => user.collection('savedPlaces')).thenReturn(places);
      when(() => places.doc('home')).thenReturn(home);
      when(() => home.set(any())).thenAnswer((_) async {});
      when(() => places.where('label', isEqualTo: 'other')).thenReturn(query);
      when(() => query.limit(20)).thenReturn(query);
      when(query.get).thenAnswer((_) async => snapshot);
      when(() => snapshot.docs).thenReturn(List.generate(20, (_) => MockDoc()));
      final source = SavedPlacesRemoteDataSource(db);
      await expectLater(
        source.addOther('u', other('')),
        throwsA(isA<SavedPlacesLimitException>()),
      );
      await source.upsert('u', savedHome);
      final data =
          verify(() => home.set(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(data['updatedAt'], isA<FieldValue>());
      expect(data['geopoint'], const GeoPoint(31, 35));
      verifyNever(() => places.add(any()));
      when(() => snapshot.docs).thenReturn(List.generate(19, (_) => MockDoc()));
      when(() => places.add(any())).thenAnswer((_) async => MockRef());
      await source.addOther('u', other(''));
      final added =
          verify(() => places.add(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(added['label'], 'other');
      expect(added['updatedAt'], isA<FieldValue>());
    },
  );
}
