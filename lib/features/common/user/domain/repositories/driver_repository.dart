import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

abstract class DriverRepository {
  Stream<Either<Failure, DriverEntity?>> watchDriver(String uid);
  Future<Either<Failure, String>> uploadLicensePhoto(
    String uid,
    Uint8List bytes,
    String contentType,
  );
  Future<Either<Failure, Unit>> submitApplication(
    String uid,
    VehicleEntity vehicle,
    String licensePhotoPath,
  );
}
