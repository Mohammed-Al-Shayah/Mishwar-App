import 'package:bloc_test/bloc_test.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class RatingSession extends MockCubit<SessionState> implements SessionCubit {}

SessionReady ratingSession({String? pending, UserRole role = UserRole.rider}) =>
    SessionReady(
      UserEntity(
        id: 'rider',
        name: 'Rider',
        phone: '+962780000001',
        role: role,
        createdAt: DateTime.utc(2026),
        pendingRatingRideId: role == UserRole.rider ? pending : null,
      ),
      driver: role == UserRole.driver
          ? DriverEntity(
              id: 'driver',
              status: DriverStatus.approved,
              isOnline: false,
              pendingRatingRideId: pending,
              vehicle: const VehicleEntity(
                type: VehicleType.economy,
                make: 'Toyota',
                model: 'Corolla',
                color: 'White',
                plate: '12-34567',
              ),
            )
          : null,
    );
RatingSession readyRatingSession({UserRole role = UserRole.rider}) {
  final session = RatingSession();
  whenListen(
    session,
    const Stream<SessionState>.empty(),
    initialState: ratingSession(role: role),
  );
  return session;
}
