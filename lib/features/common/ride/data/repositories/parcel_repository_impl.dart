import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/callable_failure.dart';
import 'package:mishwar/features/common/ride/data/datasources/parcel_remote_data_source.dart';
import 'package:mishwar/features/common/ride/domain/repositories/parcel_repository.dart';

@LazySingleton(as: ParcelRepository)
class ParcelRepositoryImpl implements ParcelRepository {
  const ParcelRepositoryImpl(this._source);
  final ParcelRemoteDataSource _source;
  Stream<Either<Failure, T>> _guard<T>(Stream<T> source) async* {
    try {
      await for (final value in source) {
        yield Right(value);
      }
    } on Object catch (error) {
      yield Left(callableFailure(error));
    }
  }

  @override
  Stream<Either<Failure, ParcelUpload>> upload(String uid, Uint8List bytes) =>
      _guard(_source.upload(uid, bytes));
  @override
  Stream<Either<Failure, String>> watchCode(String rideId) =>
      _guard(_source.watchCode(rideId));
  @override
  Future<Either<Failure, Uri>> photoUrl(String rideId) async {
    try {
      return Right(await _source.photoUrl(rideId));
    } on Object catch (error) {
      return Left(callableFailure(error));
    }
  }
}
