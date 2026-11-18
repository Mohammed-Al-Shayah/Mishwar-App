import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';

class ParcelUpload {
  const ParcelUpload(this.progress, {this.path});
  final double progress;
  final String? path;
}

abstract class ParcelRepository {
  Stream<Either<Failure, ParcelUpload>> upload(String uid, Uint8List bytes);
  Stream<Either<Failure, String>> watchCode(String rideId);
  Future<Either<Failure, Uri>> photoUrl(String rideId);
}
