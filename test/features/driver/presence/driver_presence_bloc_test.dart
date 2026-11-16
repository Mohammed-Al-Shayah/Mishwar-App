import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/location/domain/usecases/check_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_app_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/request_location_permission.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/register_push_token.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/go_offline.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/go_online.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/update_driver_location.dart';
import 'package:mishwar/features/driver/presence/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/presence_scheduler.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterPushToken extends Mock implements RegisterPushToken {}

class MockDriver extends Mock implements DriverRepository {}

class MockLocation extends Mock implements LocationRepository {}

class MockPresence extends Mock implements DriverPresenceRepository {}

class MockTracking extends Mock implements DriverTrackingRepository {}

class FakeScheduler extends PresenceScheduler {
  FakeScheduler(this.fake);
  final FakeAsync fake;
  @override
  DateTime now() => fake.getClock(DateTime.utc(2026)).now();
}

const point = GeoPointValue(31.9539, 35.9106);
DriverEntity driver({bool online = false, String? ride}) => DriverEntity(
  id: 'd',
  status: DriverStatus.approved,
  isOnline: online,
  currentRideId: ride,
  vehicle: const VehicleEntity(
    type: VehicleType.economy,
    make: 'Toyota',
    model: 'Corolla',
    color: 'White',
    plate: '123',
  ),
);
const started = Started(
  uid: 'd',
  notificationTitle: 'Title',
  notificationText: 'Text',
);

class Harness {
  Harness({PresenceScheduler? scheduler}) {
    when(() => drivers.watchDriver('d')).thenAnswer((_) => docs.stream);
    when(
      location.checkPermission,
    ).thenAnswer((_) async => const Right(LocationPermissionStatus.granted));
    when(
      location.requestPermission,
    ).thenAnswer((_) async => const Right(LocationPermissionStatus.granted));
    when(location.currentPosition).thenAnswer((_) async => const Right(point));
    when(location.openAppSettings).thenAnswer((_) async {});
    when(
      () => presence.goOnline(any(), heading: any(named: 'heading')),
    ).thenAnswer((_) async => const Right(unit));
    when(presence.goOffline).thenAnswer((_) async => const Right(unit));
    when(
      () => presence.updateLocation(any(), heading: any(named: 'heading')),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () =>
          tracking.watch(notificationTitle: 'Title', notificationText: 'Text'),
    ).thenAnswer((_) => fixes.stream);
    when(
      () => registerPush(const NoParams()),
    ).thenAnswer((_) async => const Right(unit));
    bloc = DriverPresenceBloc(
      WatchDriver(drivers),
      CheckLocationPermission(location),
      RequestLocationPermission(location),
      CurrentPosition(location),
      GoOnline(presence),
      GoOffline(presence),
      UpdateDriverLocation(presence),
      WatchDriverLocation(tracking),
      OpenAppSettings(location),
      scheduler ?? PresenceScheduler(),
      registerPush,
    );
  }
  final registerPush = MockRegisterPushToken();
  final drivers = MockDriver();
  final location = MockLocation();
  final presence = MockPresence();
  final tracking = MockTracking();
  final docs = StreamController<Either<Failure, DriverEntity?>>(
    onCancel: () async {},
  );
  final fixes = StreamController<Either<Failure, DriverFix>>(
    onCancel: () async {},
  );
  late final DriverPresenceBloc bloc;
  void start(FakeAsync fake, {bool online = false, String? ride}) {
    bloc.add(started);
    fake.flushMicrotasks();
    docs.add(Right(driver(online: online, ride: ride)));
    fake.flushMicrotasks();
  }

  void online(FakeAsync fake) {
    start(fake);
    bloc.add(const GoOnlinePressed());
    fake.flushMicrotasks();
  }

  Future<void> close() async {
    await bloc.close();
    await docs.close();
    await fixes.close();
  }
}

void main() {
  setUpAll(() => registerFallbackValue(point));
  late Harness h;
  test(
    'push registration runs once across online toggles and is non-fatal',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake));
      when(
        () => h.registerPush(const NoParams()),
      ).thenAnswer((_) async => const Left(ServerFailure('push')));
      h.online(fake);
      expect(h.bloc.state.isOnline, isTrue);
      h.bloc.add(const GoOfflinePressed());
      fake.flushMicrotasks();
      when(
        () => h.tracking.watch(
          notificationTitle: 'Title',
          notificationText: 'Text',
        ),
      ).thenAnswer((_) => const Stream<Either<Failure, DriverFix>>.empty());
      h.bloc.add(const GoOnlinePressed());
      fake.flushMicrotasks();
      expect(h.bloc.state.isOnline, isTrue);
      verify(() => h.registerPush(const NoParams())).called(1);
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  blocTest<DriverPresenceBloc, DriverPresenceState>(
    'online flow uses permission then position then presence',
    build: () {
      h = Harness();
      return h.bloc;
    },
    act: (bloc) async {
      bloc.add(started);
      await Future<void>.delayed(Duration.zero);
      h.docs.add(Right(driver()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const GoOnlinePressed());
    },
    expect: () => [
      isA<DriverPresenceState>().having(
        (s) => s.status,
        'status',
        PresenceStatus.offline,
      ),
      isA<DriverPresenceState>().having(
        (s) => s.status,
        'status',
        PresenceStatus.goingOnline,
      ),
      isA<DriverPresenceState>()
          .having((s) => s.status, 'status', PresenceStatus.online)
          .having((s) => s.lastFix!.point, 'point', point),
    ],
    verify: (_) {
      verify(() => h.presence.goOnline(point)).called(1);
    },
    tearDown: () async {
      await h.docs.close();
      await h.fixes.close();
    },
  );
  test(
    'denied permission never starts background tracking or writes',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake));
      when(
        h.location.checkPermission,
      ).thenAnswer((_) async => const Right(LocationPermissionStatus.denied));
      when(h.location.requestPermission).thenAnswer(
        (_) async => const Right(LocationPermissionStatus.deniedForever),
      );
      h.online(fake);
      expect(h.bloc.state.status, PresenceStatus.permissionDenied);
      verifyNever(() => h.presence.goOnline(any()));
      expect(h.fixes.hasListener, isFalse);
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  test(
    'three fixes are coalesced, latest sent at 5s; stationary heartbeat at 10s',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake))..online(fake);
      for (final lat in [32.0, 33.0, 34.0]) {
        h.fixes.add(Right(DriverFix(GeoPointValue(lat, 35), heading: 50)));
        fake.flushMicrotasks();
      }
      fake.elapse(const Duration(seconds: 4));
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
      fake
        ..elapse(const Duration(seconds: 1))
        ..flushMicrotasks();
      verify(
        () =>
            h.presence.updateLocation(const GeoPointValue(34, 35), heading: 50),
      ).called(1);
      fake
        ..elapse(const Duration(seconds: 5))
        ..flushMicrotasks();
      verify(
        () =>
            h.presence.updateLocation(const GeoPointValue(34, 35), heading: 50),
      ).called(1);
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  test(
    'offline cancels stream, timer and all subsequent writes',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake))..online(fake);
      h.bloc.add(const GoOfflinePressed());
      fake.flushMicrotasks();
      expect(h.bloc.state.status, PresenceStatus.offline);
      expect(h.fixes.hasListener, isFalse);
      fake
        ..elapse(const Duration(seconds: 20))
        ..flushMicrotasks();
      verify(h.presence.goOffline).called(1);
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  test(
    'reopening online resumes without reassigning presence; '
    'ride disables offline',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake))
        ..start(fake, online: true, ride: 'ride');
      expect(h.bloc.state.isOnline, isTrue);
      expect(h.bloc.state.canGoOffline, isFalse);
      expect(h.fixes.hasListener, isTrue);
      verifyNever(() => h.presence.goOnline(any()));
      h.bloc.add(const GoOfflinePressed());
      fake.flushMicrotasks();
      verifyNever(h.presence.goOffline);
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  test(
    'close cancels everything and does not write offline',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake))..online(fake);
      unawaited(h.close());
      fake
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 30))
        ..flushMicrotasks();
      expect(h.fixes.hasListener, isFalse);
      expect(h.docs.hasListener, isFalse);
      verifyNever(h.presence.goOffline);
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
    }),
  );
  test(
    'close while current position pending cannot start tracking or write',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake));
      final position = Completer<Either<Failure, GeoPointValue>>();
      when(h.location.currentPosition).thenAnswer((_) => position.future);
      h
        ..start(fake)
        ..bloc.add(const GoOnlinePressed());
      fake.flushMicrotasks();
      unawaited(h.close());
      fake.flushMicrotasks();
      position.complete(const Right(point));
      fake.flushMicrotasks();
      verifyNever(() => h.presence.goOnline(any()));
      expect(h.fixes.hasListener, isFalse);
    }),
  );
  test(
    'slow heartbeat does not overlap writes; '
    'offline waits then prevents future writes',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake));
      final pending = Completer<Either<Failure, Unit>>();
      when(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      ).thenAnswer((_) => pending.future);
      h.online(fake);
      fake
        ..elapse(const Duration(seconds: 5))
        ..flushMicrotasks();
      verify(() => h.presence.updateLocation(point)).called(1);
      h.bloc.add(const GoOfflinePressed());
      fake
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 10))
        ..flushMicrotasks();
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
      pending.complete(const Right(unit));
      fake.flushMicrotasks();
      expect(h.bloc.state.isOnline, isFalse);
      verify(h.presence.goOffline).called(1);
      fake
        ..elapse(const Duration(seconds: 20))
        ..flushMicrotasks();
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
  test(
    'authoritative offline snapshot stops tracking',
    () => fakeAsync((fake) {
      final h = Harness(scheduler: FakeScheduler(fake))..online(fake);
      h.docs.add(Right(driver()));
      fake.flushMicrotasks();
      expect(h.bloc.state.isOnline, isFalse);
      expect(h.fixes.hasListener, isFalse);
      fake
        ..elapse(const Duration(seconds: 10))
        ..flushMicrotasks();
      verifyNever(
        () => h.presence.updateLocation(any(), heading: any(named: 'heading')),
      );
      unawaited(h.close());
      fake.flushMicrotasks();
    }),
  );
}
