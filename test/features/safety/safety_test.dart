import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/validation/jordan_phone.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/safety/data/safety_remote_data_source.dart';
import 'package:mishwar/features/common/safety/data/safety_repository_impl.dart';
import 'package:mishwar/features/common/safety/data/trusted_contact_model.dart';
import 'package:mishwar/features/common/safety/domain/safety_repository.dart';
import 'package:mishwar/features/common/safety/domain/safety_usecases.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_cubit.dart';
import 'package:mishwar/features/common/safety/presentation/trusted_contacts_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/location_mocks.dart' show MockLocationRepository;
import '../history/history_data_cubit_test.dart'
    show MockCollection, MockDb, MockDoc, MockQuery, MockQuerySnapshot, MockRef;

class MockSafetySource extends Mock implements SafetyRemoteDataSource {}

class MockSafetyRepository extends Mock implements SafetyRepository {}

class MockFunctions extends Mock implements FirebaseFunctions {}

const contact = TrustedContact(id: '', name: 'Person', phone: '+962781234567');

void main() {
  setUpAll(() => registerFallbackValue(contact));
  blocTest<TrustedContactsCubit, TrustedContactsState>(
    'contacts cubit emits loaded contacts',
    build: () {
      final repository = MockSafetyRepository();
      when(
        () => repository.watch('u'),
      ).thenAnswer((_) => Stream.value(const Right([contact])));
      return TrustedContactsCubit(
        WatchTrustedContacts(repository),
        SaveTrustedContact(repository),
        DeleteTrustedContact(repository),
      );
    },
    act: (cubit) => cubit.start('u'),
    expect: () => [
      const TrustedContactsState(),
      const TrustedContactsState(contacts: [contact], loading: false),
    ],
  );
  blocTest<TripSafetyCubit, TripSafetyState>(
    'trip safety emits busy then the callable URL',
    build: () {
      final repository = MockSafetyRepository();
      when(
        () => repository.createShareLink('ride'),
      ).thenAnswer((_) async => const Right('https://example.test/t/token'));
      return TripSafetyCubit(
        CreateShareLink(repository),
        CurrentPosition(MockLocationRepository()),
      );
    },
    act: (cubit) => cubit.shareLink('ride'),
    expect: () => [
      const TripSafetyState(busy: true),
      const TripSafetyState(url: 'https://example.test/t/token'),
    ],
  );
  blocTest<TripSafetyCubit, TripSafetyState>(
    'trip safety emits share failure for retry',
    build: () {
      final repository = MockSafetyRepository();
      when(
        () => repository.createShareLink('ride'),
      ).thenAnswer((_) async => const Left(ServerFailure('offline')));
      return TripSafetyCubit(
        CreateShareLink(repository),
        CurrentPosition(MockLocationRepository()),
      );
    },
    act: (cubit) => cubit.shareLink('ride'),
    expect: () => [
      const TripSafetyState(busy: true),
      const TripSafetyState(failure: ServerFailure('offline')),
    ],
  );
  test(
    'Jordanian validator accepts national inputs and rejects malformed input',
    () {
      expect(normalizeJordanPhone('0781234567'), contact.phone);
      expect(normalizeJordanPhone('781234567'), contact.phone);
      for (final phone in [
        '+962781234567',
        '0781234567\n',
        '071',
        '0181234567',
      ]) {
        expect(normalizeJordanPhone(phone), isNull);
      }
    },
  );
  test(
    'contact validation and use case reject invalid data without writes',
    () async {
      final repository = MockSafetyRepository();
      final save = SaveTrustedContact(repository);
      for (final invalid in [
        const TrustedContact(id: '', name: '', phone: '+962781234567'),
        TrustedContact(id: '', name: 'x' * 41, phone: contact.phone),
        const TrustedContact(id: '', name: 'Person', phone: '0781234567'),
        const TrustedContact(id: '', name: 'Person', phone: '+962781234567\n'),
      ]) {
        expect((await save('u', invalid)).isLeft(), isTrue);
      }
      verifyNever(() => repository.save(any(), any()));
    },
  );
  test(
    'repository maps models, errors, mutations, limits and sharing',
    () async {
      final source = MockSafetySource();
      final repo = SafetyRepositoryImpl(source);
      when(() => source.watch('u')).thenAnswer(
        (_) => Stream.value([
          const TrustedContactModel(
            id: 'id',
            name: 'Person',
            phone: '+962781234567',
          ),
        ]),
      );
      final result = await repo.watch('u').first;
      expect(result.getOrElse((_) => []).single.id, 'id');
      when(
        () => source.watch('u'),
      ).thenAnswer((_) => Stream.error(Exception('offline')));
      expect(
        (await repo.watch('u').first).getLeft().toNullable(),
        isA<ServerFailure>(),
      );
      when(() => source.save('u', contact)).thenAnswer((_) async {});
      expect(await repo.save('u', contact), const Right<Failure, Unit>(unit));
      when(
        () => source.save('u', contact),
      ).thenThrow(const ContactsLimitException());
      expect(
        (await repo.save('u', contact)).getLeft().toNullable(),
        const ValidationFailure('trusted-contacts-limit'),
      );
      when(() => source.delete('u', 'id')).thenThrow(Exception('offline'));
      expect((await repo.delete('u', 'id')).isLeft(), isTrue);
      when(
        () => source.createShareLink('ride'),
      ).thenAnswer((_) async => 'https://example.test/t/token');
      expect(
        (await repo.createShareLink('ride')).getRight().toNullable(),
        'https://example.test/t/token',
      );
      when(
        () => source.createShareLink('ride'),
      ).thenThrow(Exception('offline'));
      expect((await repo.createShareLink('ride')).isLeft(), isTrue);
    },
  );
  test('data source checks five-contact cap before inserting', () async {
    final db = MockDb();
    final users = MockCollection();
    final user = MockRef();
    final contacts = MockCollection();
    final query = MockQuery();
    final snapshot = MockQuerySnapshot();
    when(() => db.collection('users')).thenReturn(users);
    when(() => users.doc('u')).thenReturn(user);
    when(() => user.collection('trustedContacts')).thenReturn(contacts);
    when(() => contacts.limit(5)).thenReturn(query);
    when(query.get).thenAnswer((_) async => snapshot);
    // Only the count matters; no document data is accessed.
    when(() => snapshot.docs).thenReturn(List.generate(5, (_) => MockDoc()));
    final source = SafetyRemoteDataSource(db, MockFunctions());
    await expectLater(
      source.save('u', contact),
      throwsA(isA<ContactsLimitException>()),
    );
    verifyNever(contacts.doc);
  });
  test(
    'contacts cubit enforces cap, edits, deletes and cancels its subscription',
    () async {
      final repository = MockSafetyRepository();
      final stream = StreamController<Either<Failure, List<TrustedContact>>>();
      when(() => repository.watch('u')).thenAnswer((_) => stream.stream);
      when(
        () => repository.save('u', any()),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repository.delete('u', 'id'),
      ).thenAnswer((_) async => const Right(unit));
      final cubit = TrustedContactsCubit(
        WatchTrustedContacts(repository),
        SaveTrustedContact(repository),
        DeleteTrustedContact(repository),
      );
      await cubit.start('u');
      stream.add(
        Right(
          List.generate(
            5,
            (i) =>
                TrustedContact(id: '$i', name: 'Person', phone: contact.phone),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.contacts.length, 5);
      expect(await cubit.save(contact), isFalse);
      expect(
        cubit.state.failure,
        const ValidationFailure('trusted-contacts-limit'),
      );
      verifyNever(() => repository.save(any(), any()));
      expect(await cubit.save(cubit.state.contacts.first), isTrue);
      expect(await cubit.delete('id'), isTrue);
      stream.add(const Left(ServerFailure('offline')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.failure, isA<ServerFailure>());
      await cubit.close();
      expect(stream.hasListener, isFalse);
      await stream.close();
    },
  );
}
