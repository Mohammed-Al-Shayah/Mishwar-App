import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/promos/domain/validate_promo.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimate.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/entities/route_info.dart';
import 'package:mishwar/features/common/route/domain/repositories/route_repository.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/ride_mocks.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

const draft = RideDraft(
  pickup: RideStop(
    name: 'Pickup',
    address: 'Start',
    location: GeoPointValue(38.5, -120.2),
  ),
  dropoff: RideStop(
    name: 'Park',
    address: 'End',
    location: GeoPointValue(43.252, -126.453),
  ),
);
const route = RouteInfo(
  polyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
  distanceMeters: 5000,
  durationSeconds: 600,
);
final estimates = FareEstimates(
  route: route,
  fares: const [
    FareEstimate(vehicleType: VehicleType.economy, minor: 4600),
    FareEstimate(vehicleType: VehicleType.comfort, minor: 5800),
    FareEstimate(vehicleType: VehicleType.van, minor: 7200),
  ],
);
void stubSuccess(MockRouteRepository repository) {
  when(
    () => repository.getFareEstimates(
      origin: draft.pickup.location,
      destination: draft.dropoff.location,
    ),
  ).thenAnswer((_) async => Right(estimates));
}

void main() {
  test(
    'banner draft pre-applies code with server validation after estimates',
    () async {
      final routes = MockRouteRepository();
      stubSuccess(routes);
      final promos = MockPromoRepository();
      when(
        () => promos.validate(
          'WELCOME50',
          draft.withPromo('WELCOME50'),
          VehicleType.economy,
        ),
      ).thenAnswer(
        (_) async => const Right(
          PromoQuote(
            code: 'WELCOME50',
            discountMinor: 1000,
            fareBeforeMinor: 4600,
            fareAfterMinor: 3600,
          ),
        ),
      );
      final cubit = RideConfirmCubit(
        GetFareEstimates(routes),
        requestRideStub(),
        draft.withPromo('WELCOME50'),
        scheduleRide: scheduleRideStub(),
        validatePromo: ValidatePromo(promos),
      );
      await cubit.start();
      expect((cubit.state as RideConfirmLoaded).promoQuote?.code, 'WELCOME50');
      verify(
        () => promos.validate(
          'WELCOME50',
          draft.withPromo('WELCOME50'),
          VehicleType.economy,
        ),
      ).called(1);
      await cubit.close();
    },
  );
  test(
    'promo selection debounces, discards stale quotes and sends validated code',
    () async {
      final routes = MockRouteRepository();
      stubSuccess(routes);
      final promos = MockPromoRepository();
      final first = Completer<Either<Failure, PromoQuote>>();
      const quote = PromoQuote(
        code: 'WELCOME50',
        discountMinor: 1700,
        fareBeforeMinor: 4600,
        fareAfterMinor: 2900,
      );
      when(
        () => promos.validate('welcome50', draft, VehicleType.economy),
      ).thenAnswer((_) => first.future);
      when(
        () => promos.validate('WELCOME50', draft, VehicleType.van),
      ).thenAnswer((_) async => const Right(quote));
      final request = requestRideStub(const Right('id'));
      final cubit = RideConfirmCubit(
        GetFareEstimates(routes),
        request,
        draft,
        scheduleRide: scheduleRideStub(),
        validatePromo: ValidatePromo(promos),
      );
      await cubit.start();
      final pending = cubit.applyPromo('welcome50');
      cubit
        ..select(VehicleType.comfort)
        ..select(VehicleType.van);
      first.complete(const Right(quote));
      await pending;
      expect((cubit.state as RideConfirmLoaded).promoQuote, isNull);
      await cubit.confirm();
      verifyNever(() => request(any(), any()));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect((cubit.state as RideConfirmLoaded).promoQuote, quote);
      verifyNever(() => promos.validate(any(), draft, VehicleType.comfort));
      await cubit.confirm();
      verify(
        () => request(draft.withPromo('WELCOME50'), VehicleType.van),
      ).called(1);
      await cubit.close();
    },
  );
  test(
    'removing promo invalidates an in-flight response and errors are inline',
    () async {
      final routes = MockRouteRepository();
      stubSuccess(routes);
      final promos = MockPromoRepository();
      final pending = Completer<Either<Failure, PromoQuote>>();
      when(
        () => promos.validate('CODE', draft, VehicleType.economy),
      ).thenAnswer((_) => pending.future);
      final cubit = RideConfirmCubit(
        GetFareEstimates(routes),
        requestRideStub(),
        draft,
        scheduleRide: scheduleRideStub(),
        validatePromo: ValidatePromo(promos),
      );
      await cubit.start();
      final checking = cubit.applyPromo('CODE');
      cubit.removePromo();
      pending.complete(const Left(PromoFailure('expired')));
      await checking;
      expect((cubit.state as RideConfirmLoaded).promoFailure, isNull);
      when(
        () => promos.validate('CODE', draft, VehicleType.economy),
      ).thenAnswer((_) async => const Left(PromoFailure('expired')));
      await cubit.applyPromo('CODE');
      expect(
        (cubit.state as RideConfirmLoaded).promoFailure,
        const PromoFailure('expired'),
      );
      await cubit.close();
    },
  );
  late MockRouteRepository repository;
  setUp(() {
    repository = MockRouteRepository();
    stubSuccess(repository);
  });
  RideConfirmCubit build() => RideConfirmCubit(
    GetFareEstimates(repository),
    requestRideStub(const Right('ride-id')),
    draft,
    validatePromo: promoValidatorStub(),
    scheduleRide: scheduleRideStub(),
  );
  blocTest<RideConfirmCubit, RideConfirmState>(
    'success defaults to economy',
    build: build,
    act: (c) => c.start(),
    expect: () => [
      const RideConfirmLoading(),
      RideConfirmLoaded(route: route, fares: estimates.fares),
    ],
    verify: (_) => verify(
      () => repository.getFareEstimates(
        origin: draft.pickup.location,
        destination: draft.dropoff.location,
      ),
    ).called(1),
  );
  blocTest<RideConfirmCubit, RideConfirmState>(
    'requests selected vehicle and returns ride id',
    build: build,
    act: (c) async {
      await c.start();
      c.select(VehicleType.van);
      await c.confirm();
    },
    expect: () => [
      const RideConfirmLoading(),
      isA<RideConfirmLoaded>(),
      isA<RideConfirmLoaded>().having(
        (s) => s.selected,
        'selected',
        VehicleType.van,
      ),
      isA<RideConfirmLoaded>().having((s) => s.isRequesting, 'loading', true),
      isA<RideConfirmRequested>()
          .having((s) => s.fareMinor, 'fare', 7200)
          .having((s) => s.selected, 'selected', VehicleType.van),
    ],
  );
  blocTest<RideConfirmCubit, RideConfirmState>(
    'failure then retry succeeds',
    build: () {
      when(
        () => repository.getFareEstimates(
          origin: draft.pickup.location,
          destination: draft.dropoff.location,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('offline')));
      return build();
    },
    act: (c) async {
      await c.start();
      stubSuccess(repository);
      await c.retry();
    },
    expect: () => [
      const RideConfirmLoading(),
      const RideConfirmFailure(ServerFailure('offline')),
      const RideConfirmLoading(),
      isA<RideConfirmLoaded>(),
    ],
  );
  blocTest<RideConfirmCubit, RideConfirmState>(
    'loading ignores selection and confirmation',
    build: build,
    act: (c) async {
      c.select(VehicleType.van);
      await c.confirm();
    },
    expect: () => <RideConfirmState>[],
  );
  for (final failure in [
    const ActiveRideFailure('existing'),
    const NetworkFailure('offline'),
  ]) {
    blocTest<RideConfirmCubit, RideConfirmState>(
      'request handles ${failure.runtimeType}',
      build: () => RideConfirmCubit(
        GetFareEstimates(repository),
        requestRideStub(Left(failure)),
        draft,
        validatePromo: promoValidatorStub(),
        scheduleRide: scheduleRideStub(),
      ),
      act: (c) async {
        await c.start();
        await c.confirm();
      },
      expect: () => [
        const RideConfirmLoading(),
        isA<RideConfirmLoaded>(),
        isA<RideConfirmLoaded>().having((s) => s.isRequesting, 'loading', true),
        if (failure is ActiveRideFailure)
          isA<RideConfirmRequested>().having((s) => s.rideId, 'id', 'existing')
        else
          isA<RideConfirmLoaded>().having(
            (s) => s.requestFailure,
            'failure',
            failure,
          ),
      ],
    );
  }
}
