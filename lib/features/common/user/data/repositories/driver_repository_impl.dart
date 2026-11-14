import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/data/datasources/driver_remote_data_source.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';

@LazySingleton(as: DriverRepository)
class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl(this._source);
  final DriverRemoteDataSource _source;
  Failure _failure(Object error) => switch (error) {
    FirebaseException(
      code: 'unavailable' || 'network-request-failed' || 'retry-limit-exceeded',
    ) =>
      const NetworkFailure('unavailable'),
    FirebaseException(:final code) => ServerFailure(code),
    _ => const ServerFailure('driver-error'),
  };
  @override
  Stream<Either<Failure, DriverEntity?>> watchDriver(String uid) async* {
    try {
      await for (final model in _source.watchDriver(uid)) {
        yield Right(model?.toEntity());
      }
    } on Object catch (error) {
      yield Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLicensePhoto(
    String uid,
    Uint8List bytes,
    String contentType,
  ) async {
    try {
      return Right(await _source.uploadLicensePhoto(uid, bytes, contentType));
    } on Object catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitApplication(
    String uid,
    VehicleEntity vehicle,
    String licensePhotoPath,
  ) async {
    try {
      await _source.submitApplication(
        uid,
        VehicleModel.fromEntity(vehicle),
        licensePhotoPath,
      );
      return const Right(unit);
    } on Object catch (error) {
      return Left(_failure(error));
    }
  }
}
