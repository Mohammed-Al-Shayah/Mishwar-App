import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

@lazySingleton
class ScheduleRide {
  const ScheduleRide(this._repository);
  final RideRepository _repository;
  Future<Either<Failure, String>> call(
    RideDraft draft,
    VehicleType vehicleType,
  ) => _repository.scheduleRide(draft, vehicleType);
}
