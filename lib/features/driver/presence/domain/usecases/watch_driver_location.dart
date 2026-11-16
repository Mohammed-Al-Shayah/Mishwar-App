import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart';

@lazySingleton
class WatchDriverLocation {
  const WatchDriverLocation(this._repository);
  final DriverTrackingRepository _repository;
  Stream<Either<Failure, DriverFix>> call({
    required String notificationTitle,
    required String notificationText,
  }) => _repository.watch(
    notificationTitle: notificationTitle,
    notificationText: notificationText,
  );
}
