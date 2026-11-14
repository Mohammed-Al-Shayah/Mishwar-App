import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';

String normalizePlate(String value) => value.trim().replaceAllMapped(
  RegExp('[٠-٩]'),
  (match) => (match[0]!.codeUnitAt(0) - 0x660).toString(),
);
Map<String, ValidationFailure> applicationErrors(
  VehicleEntity vehicle, {
  required bool hasPhoto,
}) {
  final errors = <String, ValidationFailure>{};
  for (final entry in {
    'make': vehicle.make,
    'model': vehicle.model,
    'color': vehicle.color,
  }.entries) {
    if (entry.value.trim().length < 2 || entry.value.trim().length > 30) {
      errors[entry.key] = ValidationFailure(entry.key, 'length');
    }
  }
  if (!RegExp(r'^\d{1,2}-\d{3,6}$').hasMatch(normalizePlate(vehicle.plate))) {
    errors['plate'] = const ValidationFailure('plate', 'format');
  }
  if (!hasPhoto) errors['photo'] = const ValidationFailure('photo', 'required');
  return errors;
}

@lazySingleton
class SubmitDriverApplication {
  const SubmitDriverApplication(this._repository);
  final DriverRepository _repository;
  Future<Either<Failure, Unit>> call(
    String uid,
    VehicleEntity vehicle,
    String licensePhotoPath,
  ) async {
    final errors = applicationErrors(
      vehicle,
      hasPhoto: licensePhotoPath.trim().isNotEmpty,
    );
    if (errors.isNotEmpty) return Left(errors.values.first);
    return _repository.submitApplication(
      uid,
      VehicleEntity(
        type: vehicle.type,
        make: vehicle.make.trim(),
        model: vehicle.model.trim(),
        color: vehicle.color.trim(),
        plate: normalizePlate(vehicle.plate),
      ),
      licensePhotoPath,
    );
  }
}
