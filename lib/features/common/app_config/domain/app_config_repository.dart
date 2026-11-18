import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/domain/airport_config.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

abstract interface class AppConfigRepository {
  Future<Either<Failure, AirportConfig?>> airportConfig();
  Stream<Either<Failure, List<AppService>>> watchServices();
  Stream<Either<Failure, List<AppBanner>>> watchBanners();
  Stream<Either<Failure, List<AppBanner>>> watchAllBanners();
}
