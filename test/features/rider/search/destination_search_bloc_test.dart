import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';
import 'package:mishwar/features/common/places/domain/repositories/places_repository.dart';
import 'package:mishwar/features/common/places/domain/usecases/get_place_details.dart';
import 'package:mishwar/features/common/places/domain/usecases/search_places.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_event.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_state.dart';
import 'package:mocktail/mocktail.dart';

class MockPlacesRepository extends Mock implements PlacesRepository {}

const suggestion = PlaceSuggestion(
  placeId: 'p',
  primaryText: 'Place',
  secondaryText: 'Street',
);
const point = GeoPointValue(31, 35);
const details = PlaceDetails(
  placeId: 'p',
  name: 'Place',
  address: 'Street',
  location: point,
);

void main() {
  late MockPlacesRepository repository;
  DestinationSearchBloc build() => DestinationSearchBloc(
    SearchPlaces(repository),
    GetPlaceDetails(repository),
    const DestinationSearchParams(position: point, language: 'en'),
  );
  setUp(() {
    repository = MockPlacesRepository();
    when(
      () => repository.search(
        input: any(named: 'input'),
        sessionToken: any(named: 'sessionToken'),
        bias: point,
        lang: 'en',
      ),
    ).thenAnswer((_) async => const Right([suggestion]));
    when(
      () => repository.details(
        placeId: 'p',
        sessionToken: any(named: 'sessionToken'),
        lang: 'en',
      ),
    ).thenAnswer((_) async => const Right(details));
  });

  test('300ms debounce searches only the last trimmed query with bias', () {
    fakeAsync((async) {
      final bloc = build()..add(const QueryChanged('Pa'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 100));
      bloc.add(const QueryChanged('Par'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 100));
      bloc.add(const QueryChanged(' Park '));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 299));
      verifyNever(
        () => repository.search(
          input: any(named: 'input'),
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      );
      async
        ..elapse(const Duration(milliseconds: 1))
        ..flushMicrotasks();
      expect(bloc.state, DestinationResults(const [suggestion]));
      verify(
        () => repository.search(
          input: 'Park',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).called(1);
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  test('short trimmed query cancels pending and active searches', () {
    fakeAsync((async) {
      final pending = Completer<Either<Failure, List<PlaceSuggestion>>>();
      when(
        () => repository.search(
          input: 'Park',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) => pending.future);
      final bloc = build()..add(const QueryChanged('Park'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      bloc.add(const QueryChanged(' a '));
      async.flushMicrotasks();
      pending.complete(const Right([suggestion]));
      async.flushMicrotasks();
      expect(bloc.state, const DestinationIdle());
      verifyNever(
        () => repository.search(
          input: 'a',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      );
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  test('drops stale results and cancels during the next debounce', () {
    fakeAsync((async) {
      final old = Completer<Either<Failure, List<PlaceSuggestion>>>();
      when(
        () => repository.search(
          input: 'Old',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) => old.future);
      final bloc = build()..add(const QueryChanged('Old'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      bloc.add(const QueryChanged('New'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      expect(bloc.state, DestinationResults(const [suggestion]));
      old.complete(const Right([]));
      async.flushMicrotasks();
      expect(bloc.state, DestinationResults(const [suggestion]));
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  blocTest<DestinationSearchBloc, DestinationSearchState>(
    'empty results',
    build: () {
      when(
        () => repository.search(
          input: 'None',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) async => const Right([]));
      return build();
    },
    act: (bloc) => bloc.add(const QueryChanged('None')),
    wait: const Duration(milliseconds: 350),
    expect: () => [
      DestinationLoading(const []),
      const DestinationEmpty('None'),
    ],
  );
  blocTest<DestinationSearchBloc, DestinationSearchState>(
    'failure and Retry',
    build: () {
      when(
        () => repository.search(
          input: 'Park',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      return build();
    },
    act: (bloc) async {
      bloc.add(const QueryChanged('Park'));
      await Future<void>.delayed(const Duration(milliseconds: 350));
      when(
        () => repository.search(
          input: 'Park',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) async => const Right([suggestion]));
      bloc.add(const Retry());
    },
    expect: () => [
      DestinationLoading(const []),
      const DestinationFailure(NetworkFailure('offline'), 'Park'),
      DestinationLoading(const []),
      DestinationResults(const [suggestion]),
    ],
  );
  test(
    'selection resolves details with session token and renews for next query',
    () {
      fakeAsync((async) {
        final bloc = build()..add(const QueryChanged('Park'));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(milliseconds: 300))
          ..flushMicrotasks();
        final tokens = verify(
          () => repository.search(
            input: 'Park',
            sessionToken: captureAny(named: 'sessionToken'),
            bias: point,
            lang: 'en',
          ),
        ).captured;
        final states = <DestinationSearchState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(const SuggestionSelected(suggestion));
        async.flushMicrotasks();
        expect(states, [
          DestinationResolving(suggestion, const [suggestion]),
          const DestinationChosen(details),
        ]);
        verify(
          () => repository.details(
            placeId: 'p',
            sessionToken: tokens.single as String,
            lang: 'en',
          ),
        ).called(1);
        bloc.add(const QueryChanged('Next'));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(milliseconds: 300))
          ..flushMicrotasks();
        final next = verify(
          () => repository.search(
            input: 'Next',
            sessionToken: captureAny(named: 'sessionToken'),
            bias: point,
            lang: 'en',
          ),
        ).captured.single;
        expect(next, isNot(tokens.single));
        unawaited(sub.cancel());
        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    },
  );
  test('short query from idle never calls search', () {
    fakeAsync((async) {
      final bloc = build()..add(const QueryChanged(' a '));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 1))
        ..flushMicrotasks();
      expect(bloc.state, const DestinationIdle());
      verifyNever(
        () => repository.search(
          input: any(named: 'input'),
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      );
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  test('previous results remain visible while a new query loads', () {
    fakeAsync((async) {
      final pending = Completer<Either<Failure, List<PlaceSuggestion>>>();
      when(
        () => repository.search(
          input: 'Next',
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).thenAnswer((_) => pending.future);
      final bloc = build()..add(const QueryChanged('Park'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      bloc.add(const QueryChanged('Next'));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      expect(bloc.state, DestinationLoading(const [suggestion]));
      pending.complete(const Right([]));
      async.flushMicrotasks();
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  test('new query cancels details and starts with a renewed token', () {
    fakeAsync((async) {
      final pending = Completer<Either<Failure, PlaceDetails>>();
      when(
        () => repository.details(
          placeId: 'p',
          sessionToken: any(named: 'sessionToken'),
          lang: 'en',
        ),
      ).thenAnswer((_) => pending.future);
      final bloc = build()..add(const SuggestionSelected(suggestion));
      async.flushMicrotasks();
      final token = verify(
        () => repository.details(
          placeId: 'p',
          sessionToken: captureAny(named: 'sessionToken'),
          lang: 'en',
        ),
      ).captured.single;
      bloc.add(const QueryChanged('Next'));
      async.flushMicrotasks();
      // A details response during the new debounce must never pop the screen.
      pending.complete(const Right(details));
      async.flushMicrotasks();
      expect(bloc.state, isNot(isA<DestinationChosen>()));
      async
        ..elapse(const Duration(milliseconds: 300))
        ..flushMicrotasks();
      final next = verify(
        () => repository.search(
          input: 'Next',
          sessionToken: captureAny(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      ).captured.single;
      expect(next, isNot(token));
      expect(bloc.state, DestinationResults(const [suggestion]));
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
  blocTest<DestinationSearchBloc, DestinationSearchState>(
    'details failure retries the selected suggestion',
    build: () {
      when(
        () => repository.details(
          placeId: 'p',
          sessionToken: any(named: 'sessionToken'),
          lang: 'en',
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('unavailable')));
      return build();
    },
    act: (bloc) async {
      bloc.add(const SuggestionSelected(suggestion));
      await Future<void>.delayed(Duration.zero);
      when(
        () => repository.details(
          placeId: 'p',
          sessionToken: any(named: 'sessionToken'),
          lang: 'en',
        ),
      ).thenAnswer((_) async => const Right(details));
      bloc.add(const Retry());
    },
    expect: () => [
      DestinationResolving(suggestion, const []),
      const DestinationFailure(ServerFailure('unavailable'), ''),
      DestinationResolving(suggestion, const []),
      const DestinationChosen(details),
    ],
  );
  test('clear cancels a pending debounce', () {
    fakeAsync((async) {
      final bloc = build()..add(const QueryChanged('Park'));
      async.flushMicrotasks();
      bloc.add(const Cleared());
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 1))
        ..flushMicrotasks();
      expect(bloc.state, const DestinationIdle());
      verifyNever(
        () => repository.search(
          input: any(named: 'input'),
          sessionToken: any(named: 'sessionToken'),
          bias: point,
          lang: 'en',
        ),
      );
      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  });
}
