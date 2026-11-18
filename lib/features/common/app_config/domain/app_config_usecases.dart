import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_repository.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

@lazySingleton
class WatchBanners {
  const WatchBanners(this._repository);
  final AppConfigRepository _repository;
  Stream<Either<Failure, List<AppBanner>>> call() => _repository.watchBanners();
}

@lazySingleton
class WatchAllBanners {
  const WatchAllBanners(this._repository);
  final AppConfigRepository _repository;
  Stream<Either<Failure, List<AppBanner>>> call() =>
      _repository.watchAllBanners();
}

@lazySingleton
class WatchServices {
  const WatchServices(this._repository);
  final AppConfigRepository _repository;
  Stream<Either<Failure, List<AppService>>> call() =>
      _repository.watchServices();
}
