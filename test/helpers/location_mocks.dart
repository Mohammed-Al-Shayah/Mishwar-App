import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';
import 'package:mishwar/features/common/location/domain/usecases/check_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_app_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/open_location_settings.dart';
import 'package:mishwar/features/common/location/domain/usecases/request_location_permission.dart';
import 'package:mishwar/features/common/location/domain/usecases/watch_position.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

RiderHomeCubit riderCubit(LocationRepository repository) => RiderHomeCubit(
  CheckLocationPermission(repository),
  RequestLocationPermission(repository),
  CurrentPosition(repository),
  WatchPosition(repository),
  OpenAppSettings(repository),
  OpenLocationSettings(repository),
);
