import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/repositories/parcel_repository.dart';

@lazySingleton
class UploadParcelPhoto {
  const UploadParcelPhoto(this._repository);
  final ParcelRepository _repository;
  Stream<Either<Failure, ParcelUpload>> call(String uid, Uint8List bytes) =>
      _repository.upload(uid, bytes);
}

@lazySingleton
class WatchDeliveryCode {
  const WatchDeliveryCode(this._repository);
  final ParcelRepository _repository;
  Stream<Either<Failure, String>> call(String rideId) =>
      _repository.watchCode(rideId);
}

@lazySingleton
class GetParcelPhotoUrl {
  const GetParcelPhotoUrl(this._repository);
  final ParcelRepository _repository;
  Future<Either<Failure, Uri>> call(String rideId) =>
      _repository.photoUrl(rideId);
}
