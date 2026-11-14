import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/app/router/app_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

void main() {
  final user = UserEntity(
    id: 'u',
    name: 'Test',
    phone: '+962791234567',
    createdAt: DateTime.utc(2026),
  );
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
