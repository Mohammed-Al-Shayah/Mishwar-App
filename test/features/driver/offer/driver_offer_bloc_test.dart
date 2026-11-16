import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/ride/domain/usecases/accept_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/decline_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/user/data/models/driver_model.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart';
import 'package:mocktail/mocktail.dart';
import '../../common/ride/ride_data_test.dart' show rideJson;
import '../presence/driver_presence_bloc_test.dart' show driver;

class MockRides extends Mock implements RideRepository {}

class MockDrivers extends Mock implements DriverRepository {}

class FakeScheduler extends OfferScheduler {
  FakeScheduler(this.time);
  final DateTime Function() time;
  @override
  DateTime now() => time();
}

class MockOfferBloc extends MockBloc<DriverOfferEvent, DriverOfferState>
    implements DriverOfferBloc {}

final RideEntity offerRide = RideModel.fromJson({
  ...rideJson(),
  'fare': {'estimated': 4.7, 'currency': 'JOD'},
  'offerDistanceMeters': 1200,
}).toEntity();
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });
  blocTest<DriverOfferBloc, DriverOfferState>(
    'accept emits offered then accepting and accepted',
    build: () {
      final rides = MockRides();
      final drivers = MockDrivers();
      final offered = DriverModel.fromEntity(driver())
          .copyWith(
            offer: DriverOfferModel(
              rideId: 'ride',
              expiresAt: DateTime.now().add(const Duration(seconds: 15)),
              seq: 1,
            ),
          )
          .toEntity();
      when(
        () => drivers.watchDriver('d'),
      ).thenAnswer((_) => Stream.value(Right(offered)));
      when(
        () => rides.watchRide('ride'),
      ).thenAnswer((_) => Stream.value(Right(offerRide)));
      when(
        () => rides.acceptRide('ride'),
      ).thenAnswer((_) async => const Right(unit));
      return DriverOfferBloc(
        WatchDriver(drivers),
        WatchRide(rides),
        AcceptRide(rides),
        DeclineRide(rides),
        OfferScheduler(),
      );
    },
    act: (bloc) async {
      bloc.add(const Started('d'));
      await bloc.stream.firstWhere(
        (state) => state.status == OfferStatus.offered,
      );
      bloc.add(const AcceptPressed());
    },
    expect: () => [
      const DriverOfferState(),
      const DriverOfferState(status: OfferStatus.loading),
      isA<DriverOfferState>().having(
        (state) => state.status,
        'status',
        OfferStatus.offered,
      ),
      isA<DriverOfferState>().having(
        (state) => state.status,
        'status',
        OfferStatus.accepting,
      ),
      isA<DriverOfferState>().having(
        (state) => state.status,
        'status',
        OfferStatus.accepted,
      ),
    ],
  );
  for (final action in [
    'expiry',
    'accept',
    'lost',
    'decline',
    'clear',
    'duplicate',
    'error',
    'accept-clear',
  ]) {
    test('offer lifecycle $action with fakeAsync', () {
      fakeAsync((async) {
        final drivers = MockDrivers();
        final rides = MockRides();
        final updates = StreamController<Either<Failure, DriverEntity?>>();
        final now = DateTime.utc(2026);
        final offer = DriverOffer(
          rideId: 'ride',
          expiresAt: now.add(const Duration(seconds: 15)),
          seq: 1,
        );
        final offeredDriver = DriverModel.fromEntity(
          driver(),
        ).copyWith(offer: DriverOfferModel.fromEntity(offer)).toEntity();
        when(() => drivers.watchDriver('d')).thenAnswer((_) => updates.stream);
        when(
          () => rides.watchRide('ride'),
        ).thenAnswer((_) => Stream.value(Right(offerRide)));
        when(() => rides.acceptRide('ride')).thenAnswer(
          (_) async => action == 'lost'
              ? const Left(OfferFailure(OfferFailureReason.expired))
              : action == 'error'
              ? const Left(NetworkFailure('offline'))
              : const Right(unit),
        );
        when(
          () => rides.declineRide('ride'),
        ).thenAnswer((_) async => const Right(unit));
        final bloc = DriverOfferBloc(
          WatchDriver(drivers),
          WatchRide(rides),
          AcceptRide(rides),
          DeclineRide(rides),
          FakeScheduler(() => now.add(async.elapsed)),
        );
        final states = <DriverOfferState>[];
        final subscription = bloc.stream.listen(states.add);
        bloc.add(const Started('d'));
        async.flushMicrotasks();
        updates.add(Right(offeredDriver));
        async.flushMicrotasks();
        expect(bloc.state.status, OfferStatus.offered);
        expect(bloc.state.remaining.inSeconds, 15);
        async
          ..elapse(const Duration(seconds: 1))
          ..flushMicrotasks();
        expect(bloc.state.remaining.inSeconds, 14);
        switch (action) {
          case 'expiry':
            async
              ..elapse(const Duration(seconds: 14))
              ..flushMicrotasks();
            expect(bloc.state.status, OfferStatus.expired);
            async
              ..elapse(const Duration(milliseconds: 1500))
              ..flushMicrotasks();
            expect(bloc.state.status, OfferStatus.idle);
            verifyNever(() => rides.declineRide(any()));
          case 'accept' || 'accept-clear':
            if (action == 'accept-clear') {
              final response = Completer<Either<Failure, Unit>>();
              when(
                () => rides.acceptRide('ride'),
              ).thenAnswer((_) => response.future);
              bloc.add(const AcceptPressed());
              async.flushMicrotasks();
              updates.add(Right(driver()));
              async.flushMicrotasks();
              expect(bloc.state.status, OfferStatus.accepting);
              response.complete(const Right(unit));
            } else {
              bloc.add(const AcceptPressed());
            }
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.accepted);
            expect(bloc.state.ride!.id, 'ride');
          case 'lost':
            bloc.add(const AcceptPressed());
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.lost);
            async
              ..elapse(const Duration(milliseconds: 1500))
              ..flushMicrotasks();
            expect(bloc.state.status, OfferStatus.idle);
          case 'decline':
            bloc.add(const DeclinePressed());
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.idle);
            verify(() => rides.declineRide('ride')).called(1);
          case 'clear':
            updates.add(Right(driver()));
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.idle);
          case 'duplicate':
            updates.add(Right(offeredDriver));
            async.flushMicrotasks();
            verify(() => rides.watchRide('ride')).called(1);
            updates.add(Right(driver()));
            async.flushMicrotasks();
            updates.add(Right(offeredDriver));
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.idle);
          case 'error':
            bloc.add(const AcceptPressed());
            async.flushMicrotasks();
            expect(bloc.state.status, OfferStatus.offered);
            expect(bloc.state.failure, isA<NetworkFailure>());
        }
        expect(states, isNotEmpty);
        unawaited(subscription.cancel());
        unawaited(bloc.close());
        unawaited(updates.close());
        async.flushMicrotasks();
      });
    });
  }
}
