import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/data/airport_config_parser.dart';
import 'package:mishwar/features/common/app_config/data/app_config_remote_data_source.dart';
import 'package:mishwar/features/common/app_config/data/app_service_model.dart';
import 'package:mishwar/features/common/app_config/domain/airport_config.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_repository.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

@LazySingleton(as: AppConfigRepository)
class AppConfigRepositoryImpl implements AppConfigRepository {
  const AppConfigRepositoryImpl(this._remote);
  final AppConfigRemoteDataSource _remote;
  @override
  Future<Either<Failure, AirportConfig?>> airportConfig() async {
    try {
      return Right(parseAirportConfig(await _remote.appConfig()));
    } on Object {
      return const Left(ServerFailure('airport'));
    }
  }

  @override
  Stream<Either<Failure, List<AppService>>> watchServices() async* {
    try {
      await for (final data in _remote.watchServices()) {
        yield Right(AppServiceModel.parseServices(data));
      }
    } on Object {
      yield const Left(ServerFailure('services'));
    }
  }

  @override
  Stream<Either<Failure, List<AppBanner>>> watchAllBanners() async* {
    try {
      await for (final models in _remote.watchBanners(all: true)) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } on Object {
      yield const Left(ServerFailure('banners'));
    }
  }

  @override
  Stream<Either<Failure, List<AppBanner>>> watchBanners() {
    // Query timestamps are fixed. Also re-filter at expiry while home is idle.
    late StreamController<Either<Failure, List<AppBanner>>> controller;
    StreamSubscription<dynamic>? subscription;
    Timer? expiry;
    var banners = <AppBanner>[];
    void publish() {
      expiry?.cancel();
      final now = clock.now();
      final valid =
          banners.where((b) => b.active && b.validUntil.isAfter(now)).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      controller.add(Right(List.unmodifiable(valid)));
      if (valid.isNotEmpty) {
        final next = valid
            .map((b) => b.validUntil)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        expiry = Timer(next.difference(now), publish);
      }
    }

    controller = StreamController(
      onListen: () {
        subscription = _remote.watchBanners().listen(
          (models) {
            try {
              banners = models.map((m) => m.toEntity()).toList();
              publish();
            } on Object {
              expiry?.cancel();
              banners = [];
              controller.add(const Left(ServerFailure('banners')));
            }
          },
          onError: (Object error) {
            expiry?.cancel();
            controller.add(const Left(ServerFailure('banners')));
          },
        );
      },
      onCancel: () async {
        expiry?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }
}
