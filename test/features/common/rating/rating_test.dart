import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/rating/domain/rate_ride.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/domain/skip_rating.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';
import '../ride/ride_data_test.dart' show MockSource;

void main() {
  late MockRideRepository repository;
  RatingCubit cubit([RatingSide side = RatingSide.rider]) =>
      RatingCubit(RateRide(repository), SkipRating(repository), 'ride', side);
  setUp(() {
    repository = MockRideRepository();
  });
  test('use cases forward exact payload and failures', () async {
    when(
      () => repository.rateRide('ride', 5, [RatingTag.friendly], 'Thanks'),
    ).thenAnswer((_) async => const Right(unit));
    expect(
      await RateRide(repository)('ride', 5, [RatingTag.friendly], 'Thanks'),
      const Right<Failure, Unit>(unit),
    );
    when(
      () => repository.skipRating('ride'),
    ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
    expect(
      await SkipRating(repository)('ride'),
      const Left<Failure, Unit>(NetworkFailure('offline')),
    );
  });
  test('repository serializes tag values and maps callable failures', () async {
    final source = MockSource();
    final repo = RideRepositoryImpl(source);
    when(() => source.rate(any())).thenAnswer((_) async {});
    expect(
      await repo.rateRide('ride', 5, [RatingTag.safeDriving], 'ok'),
      const Right<Failure, Unit>(unit),
    );
    verify(
      () => source.rate({
        'rideId': 'ride',
        'stars': 5,
        'tags': ['safe_driving'],
        'comment': 'ok',
      }),
    ).called(1);
    when(() => source.rate(any())).thenThrow(
      FirebaseFunctionsException(code: 'already-exists', message: 'duplicate'),
    );
    expect(
      await repo.rateRide('ride', 5, [], ''),
      const Left<Failure, Unit>(RatingFailure.alreadyRated()),
    );
    when(
      () => source.rate(any()),
    ).thenThrow(
      FirebaseFunctionsException(code: 'unavailable', message: 'offline'),
    );
    expect(
      (await repo.rateRide('ride', 5, [], '')).getLeft().toNullable(),
      isA<NetworkFailure>(),
    );
    when(() => source.skipRating('ride')).thenAnswer((_) async {});
    expect(await repo.skipRating('ride'), const Right<Failure, Unit>(unit));
    when(
      () => source.skipRating('ride'),
    ).thenThrow(
      FirebaseFunctionsException(code: 'permission-denied', message: 'denied'),
    );
    expect((await repo.skipRating('ride')).isLeft(), isTrue);
  });
  test(
    'tag sets switch and remove incompatible selections, capped at five',
    () async {
      final c = cubit();
      addTearDown(c.close);
      c
        ..selectStars(5)
        ..toggleTag(RatingTag.cleanCar)
        ..setComment('hello');
      expect(c.state.tags, [RatingTag.cleanCar]);
      c.selectStars(2);
      expect(c.state.tags, isEmpty);
      expect(c.state.comment, 'hello');
      expect(c.availableTags, contains(RatingTag.dirtyCar));
      c.toggleTag(RatingTag.cleanCar);
      expect(c.state.tags, isEmpty);
      c
        ..selectStars(0)
        ..selectStars(6);
      expect(c.state.stars, 2);
      c.setComment('x' * 301);
      expect(c.state.comment, 'hello');
      final driver = cubit(RatingSide.driver);
      addTearDown(driver.close);
      driver.selectStars(4);
      driver.availableTags.forEach(driver.toggleTag);
      expect(driver.state.tags, hasLength(5));
      driver.selectStars(1);
      expect(driver.state.tags, hasLength(5));
      driver.toggleTag(RatingTag.rude);
      expect(driver.state.tags, hasLength(4));
    },
  );
  blocTest<RatingCubit, RatingState>(
    'submit emits submitting and success',
    build: () {
      when(
        () => repository.rateRide('ride', 5, [], ''),
      ).thenAnswer((_) async => const Right(unit));
      return cubit();
    },
    act: (c) async {
      c.selectStars(5);
      await c.submit();
    },
    expect: () => [
      const RatingState(stars: 5),
      const RatingState(stars: 5, status: RatingStatus.submitting),
      const RatingState(stars: 5, status: RatingStatus.success),
    ],
  );
  blocTest<RatingCubit, RatingState>(
    'already rated clears pending pointer and succeeds',
    build: () {
      when(
        () => repository.rateRide('ride', 4, [], ''),
      ).thenAnswer((_) async => const Left(RatingFailure.alreadyRated()));
      when(
        () => repository.skipRating('ride'),
      ).thenAnswer((_) async => const Right(unit));
      return cubit();
    },
    act: (c) async {
      c.selectStars(4);
      await c.submit();
    },
    expect: () => [
      const RatingState(stars: 4),
      const RatingState(stars: 4, status: RatingStatus.submitting),
      const RatingState(stars: 4, status: RatingStatus.success),
    ],
  );
  blocTest<RatingCubit, RatingState>(
    'skip works with zero stars',
    build: () {
      when(
        () => repository.skipRating('ride'),
      ).thenAnswer((_) async => const Right(unit));
      return cubit();
    },
    act: (c) => c.skip(),
    expect: () => [
      const RatingState(status: RatingStatus.submitting),
      const RatingState(status: RatingStatus.success),
    ],
  );
  test(
    'errors preserve draft, retry works, busy prevents duplicates and edits',
    () async {
      final pending = Completer<Either<Failure, Unit>>();
      when(
        () => repository.rateRide('ride', 3, [], 'note'),
      ).thenAnswer((_) => pending.future);
      final c = cubit();
      addTearDown(c.close);
      await c.submit();
      verifyNever(() => repository.rateRide(any(), any(), any(), any()));
      c
        ..selectStars(3)
        ..setComment('note');
      final sending = c.submit();
      await c.submit();
      await c.skip();
      c
        ..selectStars(5)
        ..setComment('changed');
      expect(c.state.stars, 3);
      expect(c.state.comment, 'note');
      pending.complete(const Left(NetworkFailure('offline')));
      await sending;
      expect(c.state.status, RatingStatus.failure);
      expect(c.state.failure, isA<NetworkFailure>());
      when(
        () => repository.rateRide('ride', 3, [], 'note'),
      ).thenAnswer((_) async => const Right(unit));
      await c.submit();
      expect(c.state.status, RatingStatus.success);
    },
  );
}
