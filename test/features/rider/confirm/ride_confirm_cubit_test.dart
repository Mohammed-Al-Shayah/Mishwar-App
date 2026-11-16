import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
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
    FareEstimate(vehicleType: VehicleType.economy, fils: 4600),
    FareEstimate(vehicleType: VehicleType.comfort, fils: 5800),
    FareEstimate(vehicleType: VehicleType.van, fils: 7200),
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
  late MockRouteRepository repository;
  setUp(() {
    repository = MockRouteRepository();
    stubSuccess(repository);
  });
  RideConfirmCubit build() => RideConfirmCubit(
    GetFareEstimates(repository),
    requestRideStub(const Right('ride-id')),
    draft,
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
          .having((s) => s.fareFils, 'fare', 7200)
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
