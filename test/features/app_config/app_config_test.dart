import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/app_config/data/app_banner_model.dart';
import 'package:mishwar/features/common/app_config/data/app_config_remote_data_source.dart';
import 'package:mishwar/features/common/app_config/data/app_config_repository_impl.dart';
import 'package:mishwar/features/common/app_config/data/app_service_model.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_repository.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockConfigRemote extends Mock implements AppConfigRemoteDataSource {}

class MockConfigRepository extends Mock implements AppConfigRepository {}

AppBanner demoBanner({
  String id = 'a',
  BannerAction action = BannerAction.openSearch,
  int order = 0,
}) => AppBanner(
  id: id,
  title: 'Offer $id',
  subtitle: 'A ride for you',
  imageUrl: 'https://picsum.photos/seed/$id/800/400',
  action: action,
  order: order,
  validUntil: DateTime(2099),
  active: true,
  promoCode: action == BannerAction.openPromo ? 'WELCOME50' : null,
  url: action == BannerAction.url ? 'https://example.com' : null,
);
void main() {
  blocTest<AppConfigCubit, AppConfigState>(
    'banner failures emit a safe empty state',
    build: () {
      final repo = MockConfigRepository();
      when(
        repo.watchBanners,
      ).thenAnswer((_) => Stream.value(const Left(ServerFailure('banners'))));
      when(repo.watchServices).thenAnswer((_) => const Stream.empty());
      return AppConfigCubit(WatchBanners(repo), WatchServices(repo));
    },
    act: (cubit) => cubit.start('u'),
    expect: () => [
      AppConfigState(),
      AppConfigState(failure: const ServerFailure('banners')),
    ],
  );

  test(
    'missing config doc or services field defaults to ride/schedule on',
    () async {
      final remote = MockConfigRemote();
      when(remote.watchServices).thenAnswer(
        (_) => Stream.fromIterable([
          null,
          {},
          {'other': true},
        ]),
      );
      final results = await AppConfigRepositoryImpl(
        remote,
      ).watchServices().toList();
      for (final result in results) {
        expect(
          result,
          const Right<Failure, List<AppService>>(AppService.defaults),
        );
      }
    },
  );
  test(
    'services map flags and numeric order with stable ties; reject malformed',
    () {
      final services = AppServiceModel.parseServices({
        'services': [
          {'id': 'ride', 'enabled': true, 'order': 2},
          {'id': 'schedule', 'enabled': false, 'order': 1},
          {'id': 'parcel', 'enabled': false, 'order': 0},
          {'id': 'airport', 'enabled': true, 'order': 1},
        ],
      });
      expect(services.map((s) => s.id), [
        ServiceId.parcel,
        ServiceId.schedule,
        ServiceId.airport,
        ServiceId.ride,
      ]);
      expect(services.last.enabled, isTrue);
      expect(services[1].enabled, isFalse);
      expect(
        () => AppServiceModel.parseServices({'services': <Object>[]}),
        throwsFormatException,
      );
    },
  );
  test(
    'cubit merges streams, defaults on failure, cancels account subscriptions',
    () async {
      final repo = MockConfigRepository();
      final banners =
          StreamController<Either<Failure, List<AppBanner>>>.broadcast();
      final services =
          StreamController<Either<Failure, List<AppService>>>.broadcast();
      when(repo.watchBanners).thenAnswer((_) => banners.stream);
      when(repo.watchServices).thenAnswer((_) => services.stream);
      final cubit = AppConfigCubit(WatchBanners(repo), WatchServices(repo));
      await cubit.start('one');
      banners.add(Right([demoBanner()]));
      services.add(
        const Right([AppService(id: ServiceId.ride, enabled: false, order: 0)]),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.banners, hasLength(1));
      expect(cubit.state.services.single.enabled, isFalse);
      services.add(const Left(ServerFailure('offline')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.services, AppService.defaults);
      expect(cubit.state.banners, hasLength(1));
      await cubit.start('two');
      expect(cubit.state.banners, isEmpty);
      await cubit.stop();
      expect(banners.hasListener, isFalse);
      expect(services.hasListener, isFalse);
      await cubit.close();
      await banners.close();
      await services.close();
    },
  );

  test('maps banner Timestamp, actions and optional targets', () {
    for (final action in ['open_search', 'open_promo', 'url']) {
      final model = AppBannerModel.fromJson({
        'id': 'a',
        'title': 'Offer',
        'subtitle': 'Details',
        'imageUrl': 'https://example.com/a',
        'action': action,
        'order': 2,
        'validUntil': Timestamp.fromDate(DateTime.utc(2027)),
        'active': true,
        'promoCode': 'WELCOME50',
        'url': 'https://example.com',
      });
      expect(
        model.toEntity().action,
        BannerAction.values[[
          'open_search',
          'open_promo',
          'url',
        ].indexOf(action)],
      );
      expect(model.toEntity().validUntil, DateTime.utc(2027));
      expect(model.toEntity().promoCode, 'WELCOME50');
    }
  });
  test(
    'repository filters inactive/expired, orders, and expires without snapshots',
    () {
      fakeAsync((async) {
        final remote = MockConfigRemote();
        final now = clock.now();
        AppBannerModel model(
          String id,
          int order, {
          bool active = true,
          int seconds = 60,
        }) => AppBannerModel(
          id: id,
          title: id,
          subtitle: '',
          imageUrl: 'https://example.com',
          action: 'open_search',
          order: order,
          validUntil: now.add(Duration(seconds: seconds)),
          active: active,
        );
        when(remote.watchBanners).thenAnswer(
          (_) => Stream.value([
            model('late', 5),
            model('first', 1, seconds: 5),
            model('old', 0, seconds: -1),
            model('off', 0, active: false),
          ]),
        );
        final results = <List<AppBanner>>[];
        final subscription = AppConfigRepositoryImpl(remote)
            .watchBanners()
            .listen(
              (r) => r.fold((_) => fail('unexpected failure'), results.add),
            );
        async.flushMicrotasks();
        expect(results.last.map((b) => b.id), ['first', 'late']);
        async.elapse(const Duration(seconds: 5));
        expect(results.last.map((b) => b.id), ['late']);
        unawaited(subscription.cancel());
        async.flushMicrotasks();
        expect(async.pendingTimers, isEmpty);
      });
    },
  );
  test('repository maps stream/mapping errors to failure', () async {
    final remote = MockConfigRemote();
    when(
      remote.watchBanners,
    ).thenAnswer((_) => Stream.error(StateError('offline')));
    expect(
      await AppConfigRepositoryImpl(remote).watchBanners().first,
      const Left<Failure, List<AppBanner>>(ServerFailure('banners')),
    );
  });
  test(
    'app singleton starts once, updates, resets and cancels on sign out',
    () async {
      final repo = MockConfigRepository();
      final feed =
          StreamController<Either<Failure, List<AppBanner>>>.broadcast();
      when(repo.watchBanners).thenAnswer((_) => feed.stream);
      when(repo.watchServices).thenAnswer((_) => const Stream.empty());
      final cubit = AppConfigCubit(WatchBanners(repo), WatchServices(repo));
      await cubit.start('u');
      await cubit.start('u');
      verify(repo.watchBanners).called(1);
      feed.add(Right([demoBanner()]));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.banners, hasLength(1));
      await cubit.stop();
      expect(cubit.state.banners, isEmpty);
      expect(feed.hasListener, isFalse);
      await cubit.close();
      await feed.close();
    },
  );
}
