import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart';
import 'package:mishwar/features/common/ride/domain/usecases/request_ride.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockRideRepository extends Mock implements RideRepository {}

class MockRequestRide extends Mock implements RequestRide {}

RequestRide requestRideStub([
  Either<Failure, String> result = const Left(ServerFailure('offline')),
]) {
  registerFallbackValue(
    const RideDraft(
      pickup: RideStop(name: '', address: '', location: GeoPointValue(0, 0)),
      dropoff: RideStop(name: '', address: '', location: GeoPointValue(0, 0)),
    ),
  );
  registerFallbackValue(VehicleType.economy);
  final request = MockRequestRide();
  when(() => request(any(), any())).thenAnswer((_) async => result);
  return request;
}

WatchActiveRideId emptyActiveRideWatch() {
  final repository = MockRideRepository();
  when(
    () => repository.watchActiveRideId(any()),
  ).thenAnswer((_) => const Stream.empty());
  return WatchActiveRideId(repository);
}
