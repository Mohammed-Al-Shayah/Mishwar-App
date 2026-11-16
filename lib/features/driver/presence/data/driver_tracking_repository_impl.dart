import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/driver/presence/data/driver_location_source.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';

@LazySingleton(as: DriverTrackingRepository)
class DriverTrackingRepositoryImpl implements DriverTrackingRepository {
  const DriverTrackingRepositoryImpl(this._source);
  final DriverLocationSource _source;
  @override
  Stream<Either<Failure, DriverFix>> watch({
    required String notificationTitle,
    required String notificationText,
  }) async* {
    try {
      await for (final fix in _source.watch(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
      )) {
        yield Right(fix);
      }
    } on Object catch (error) {
      yield Left(
        LocationFailure(switch (error) {
          PermissionDeniedException() => LocationFailureCode.permissionDenied,
          LocationServiceDisabledException() =>
            LocationFailureCode.serviceDisabled,
          _ => LocationFailureCode.unknown,
        }),
      );
    }
  }
}
