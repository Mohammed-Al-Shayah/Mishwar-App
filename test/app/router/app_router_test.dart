import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';

void main() {
  final user = UserEntity(
    id: 'u',
    name: 'Test',
    phone: '+962791234567',
    createdAt: DateTime.utc(2026),
  );
  test('account routes follow role changes and driver approval', () {
    final rider = SessionReady(user.copyWith(role: UserRole.rider));
    final driverUser = user.copyWith(role: UserRole.driver);
    const vehicle = VehicleEntity(
      type: VehicleType.economy,
      make: 'Toyota',
      model: 'Corolla',
      color: 'White',
      plate: '12-34567',
    );
    final approved = SessionReady(
      driverUser,
      driver: const DriverEntity(
        id: 'u',
        status: DriverStatus.approved,
        isOnline: false,
        vehicle: vehicle,
      ),
    );
    final pending = SessionReady(
      driverUser,
      driver: const DriverEntity(
        id: 'u',
        status: DriverStatus.pending,
        isOnline: false,
        vehicle: vehicle,
      ),
    );
    expect(sessionRedirect(rider, '/rider/account'), isNull);
    expect(sessionRedirect(approved, '/driver/account'), isNull);
    for (final oldPath in ['/rider/account', '/rider/history', '/rider']) {
      expect(
        sessionRedirect(SessionReady(driverUser), oldPath),
        '/driver/onboarding',
      );
      expect(sessionRedirect(pending, oldPath), '/driver/pending');
      expect(sessionRedirect(approved, oldPath), '/driver');
    }
    for (final oldPath in ['/driver/account', '/driver/earnings', '/driver']) {
      expect(sessionRedirect(rider, oldPath), '/rider');
    }
    expect(
      sessionRedirect(const SessionSignedOut(), '/rider/account'),
      '/auth/phone',
    );
    expect(
      sessionRedirect(const SessionSignedOut(), '/driver/account'),
      '/auth/phone',
    );
  });
  test(
    'summary allows no active ride; pending rating redirects home',
    () {
      final rider = SessionReady(user.copyWith(role: UserRole.rider));
      const path = '/rider/ride/completed/summary';
      expect(sessionRedirect(rider, path), isNull);
      expect(sessionRedirect(const SessionSignedOut(), path), '/auth/phone');
      final pending = SessionReady(
        user.copyWith(role: UserRole.rider, pendingRatingRideId: 'completed'),
      );
      expect(sessionRedirect(pending, '/rider'), path);
      expect(sessionRedirect(pending, path), isNull);
    },
  );
  test(
    'driver pending rating reopens rate route and clears after session update',
    () {
      const vehicle = VehicleEntity(
        type: VehicleType.economy,
        make: 'Toyota',
        model: 'Corolla',
        color: 'White',
        plate: '12-34567',
      );
      final ready = SessionReady(
        user.copyWith(role: UserRole.driver),
        driver: const DriverEntity(
          id: 'u',
          status: DriverStatus.approved,
          isOnline: false,
          vehicle: vehicle,
          pendingRatingRideId: 'completed',
        ),
      );
      expect(sessionRedirect(ready, '/driver'), '/driver/ride/completed/rate');
      expect(sessionRedirect(ready, '/driver/ride/completed/rate'), isNull);
      expect(
        sessionRedirect(
          const SessionSignedOut(),
          '/driver/ride/completed/rate',
        ),
        '/auth/phone',
      );
      final cleared = SessionReady(
        user.copyWith(role: UserRole.driver),
        driver: const DriverEntity(
          id: 'u',
          status: DriverStatus.approved,
          isOnline: false,
          vehicle: vehicle,
        ),
      );
      expect(sessionRedirect(cleared, '/driver'), isNull);
    },
  );
  const stop = RideStop(
    name: 'Place',
    address: 'Street',
    location: GeoPointValue(31, 35),
  );
  const draft = RideDraft(pickup: stop, dropoff: stop);
  for (final path in ['/rider/search', '/rider/confirm']) {
    final extra = path == '/rider/search'
        ? const DestinationSearchParams()
        : draft;
    test('$path requires valid extra and ready rider session', () {
      final rider = SessionReady(user.copyWith(role: UserRole.rider));
      expect(sessionRedirect(rider, path, extra: extra), isNull);
      expect(sessionRedirect(rider, path), '/rider');
      expect(sessionRedirect(rider, path, extra: 'invalid'), '/rider');
      expect(
        sessionRedirect(const SessionSignedOut(), path, extra: extra),
        '/auth/phone',
      );
      expect(
        sessionRedirect(
          SessionReady(user.copyWith(role: UserRole.driver)),
          path,
          extra: extra,
        ),
        '/driver/onboarding',
      );
    });
  }
  test('tracking route requires a ready rider and no draft extra', () {
    const path = '/rider/ride/ride-id';
    expect(
      sessionRedirect(SessionReady(user.copyWith(role: UserRole.rider)), path),
      isNull,
    );
    expect(sessionRedirect(const SessionSignedOut(), path), '/auth/phone');
    expect(
      sessionRedirect(SessionReady(user.copyWith(role: UserRole.driver)), path),
      '/driver/onboarding',
    );
    expect(
      sessionRedirect(
        SessionReady(user.copyWith(role: UserRole.rider)),
        '/rider/ride/',
      ),
      '/rider',
    );
  });
  const otp = OtpSession(phone: '+962791234567');
  final table = <SessionState, String>{
    const SessionUnknown(): '/splash',
    const SessionSignedOut(): '/auth/phone',
    const SessionNeedsName(AuthUser(uid: 'u')): '/auth/name',
    SessionNeedsRole(user): '/role',
    SessionReady(user.copyWith(role: UserRole.rider)): '/rider',
    SessionReady(user.copyWith(role: UserRole.driver)): '/driver/onboarding',
    const SessionError(ServerFailure('secret')): '/splash',
  };
  for (final entry in table.entries) {
    for (final path in [
      '/splash',
      '/auth/phone',
      '/auth/otp',
      '/auth/name',
      '/role',
      '/rider',
      '/driver',
      '/unknown',
    ]) {
      test('${entry.key.runtimeType} at $path redirects to ${entry.value}', () {
        expect(
          sessionRedirect(entry.key, path),
          path == entry.value ? null : entry.value,
        );
      });
    }
  }
  for (final status in DriverStatus.values) {
    for (final path in [
      '/driver',
      '/driver/onboarding',
      '/driver/pending',
      '/rider',
      '/auth/phone',
    ]) {
      test('driver status $status at $path', () {
        final driver = DriverEntity(
          id: 'u',
          status: status,
          isOnline: false,
          vehicle: const VehicleEntity(
            type: VehicleType.economy,
            make: 'Toyota',
            model: 'Corolla',
            color: 'White',
            plate: '12-34567',
          ),
        );
        final target = status == DriverStatus.approved
            ? '/driver'
            : status == DriverStatus.rejected && path == '/driver/onboarding'
            ? '/driver/onboarding'
            : '/driver/pending';
        expect(
          sessionRedirect(
            SessionReady(user.copyWith(role: UserRole.driver), driver: driver),
            path,
          ),
          path == target ? null : target,
        );
      });
    }
  }
  test('signed-out OTP route requires session extra', () {
    expect(
      sessionRedirect(const SessionSignedOut(), '/auth/otp', extra: otp),
      isNull,
    );
    expect(
      sessionRedirect(const SessionSignedOut(), '/auth/otp', extra: 'bad'),
      '/auth/phone',
    );
    expect(
      sessionRedirect(
        const SessionNeedsName(AuthUser(uid: 'u')),
        '/auth/otp',
        extra: otp,
      ),
      '/auth/name',
    );
  });
}
