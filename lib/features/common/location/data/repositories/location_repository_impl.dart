import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/location/data/datasources/location_data_source.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._source);
  final LocationDataSource _source;
  LocationFailure _failure(Object error) => LocationFailure(switch (error) {
    TimeoutException() => LocationFailureCode.timeout,
    PermissionDeniedException() => LocationFailureCode.permissionDenied,
    LocationServiceDisabledException() => LocationFailureCode.serviceDisabled,
    _ => LocationFailureCode.unknown,
  });
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Exception catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, LocationPermissionStatus>> checkPermission() =>
      _guard(_source.permission);
  @override
  Future<Either<Failure, LocationPermissionStatus>> requestPermission() =>
      _guard(() => _source.permission(request: true));
  @override
  Future<Either<Failure, GeoPointValue>> currentPosition() => _guard(() async {
    final p = await _source.currentPosition();
    return GeoPointValue(p.latitude, p.longitude);
  });
  @override
  Stream<Either<Failure, GeoPointValue>> watchPosition() async* {
    try {
      await for (final p in _source.watchPosition()) {
        yield Right(GeoPointValue(p.latitude, p.longitude));
      }
    } on Exception catch (error) {
      yield Left(_failure(error));
    }
  }

  @override
  Future<void> openAppSettings() => _source.openAppSettings();
  @override
  Future<void> openLocationSettings() => _source.openLocationSettings();
}
