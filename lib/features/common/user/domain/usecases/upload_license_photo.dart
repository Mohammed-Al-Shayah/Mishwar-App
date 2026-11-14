import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart';

@lazySingleton
class UploadLicensePhoto {
  const UploadLicensePhoto(this._repository);
  final DriverRepository _repository;
  Future<Either<Failure, String>> call(
    String uid,
    Uint8List bytes,
    String contentType,
  ) => _repository.uploadLicensePhoto(uid, bytes, contentType);
}
