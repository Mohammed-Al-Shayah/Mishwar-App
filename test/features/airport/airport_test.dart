import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/app_config/data/airport_config_parser.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_repository.dart';
import 'package:mishwar/features/common/app_config/domain/app_config_usecases.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/route/data/models/route_models.dart';
import 'package:mishwar/features/common/route/domain/entities/fare_estimates.dart';
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/airport/presentation/airport_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';
import '../parcel/parcel_test.dart' show MockLocation, MockRideSource;
import '../rider/confirm/ride_confirm_cubit_test.dart'
    show MockRouteRepository, draft, estimates;

class MockAirportConfigRepository extends Mock implements AppConfigRepository {}

Map<String, dynamic> airportJson() => {
  'airport': {
    'zone': {
      'type': 'Polygon',
      'coordinates': [
        [
          [35.965, 31.705],
          [36.015, 31.705],
          [36.015, 31.745],
          [35.965, 31.745],
          [35.965, 31.705],
        ],
      ],
    },
    'pickupPoints': [
      {'id': 'gate1', 'name': 'Gate 1', 'lat': 31.7226, 'lng': 35.9932},
      {'id': 'gate3', 'name': 'Gate 3', 'lat': 31.7228, 'lng': 35.9935},
    ],
  },
};

void main() {
  test(
    'config computes polygon centroid and pickup points without fare data',
    () {
      final config = parseAirportConfig(airportJson())!;
      expect(config.centroid.lat, closeTo(31.725, 1e-7));
      expect(config.centroid.lng, closeTo(35.99, 1e-7));
      expect(config.pickupPoints.map((p) => p.name), ['Gate 1', 'Gate 3']);
      final persisted = airportJson();
      final airport = persisted['airport'] as Map<String, dynamic>;
      airport['zone'] = jsonEncode(airport['zone']);
      expect(parseAirportConfig(persisted), config);
      expect(parseAirportConfig(null), isNull);
      expect(parseAirportConfig({'airport': <String, dynamic>{}}), isNull);
    },
  );

  test('flight numbers normalize and reject invalid formats', () {
    for (final value in ['rj 182', 'rj182', 'a1 2b']) {
      expect(normalizeFlightNumber(' $value '), value.toUpperCase());
    }
    for (final value in ['', 'RJ', 'RJ  182', 'R!182', 'RJ12345']) {
      expect(normalizeFlightNumber(value), isNull);
    }
  });

  test(
    'server estimates deserialize airport direction, with legacy fallback',
    () {
      final data = {
        'route': {'polyline': 'abc', 'distanceMeters': 1, 'durationSeconds': 1},
        'fares': [
          {'vehicleType': 'economy', 'amount': 12, 'currency': 'JOD'},
        ],
      };
      expect(FareEstimatesModel.fromJson(data).toEntity().airport, isNull);
      final parsed = FareEstimatesModel.fromJson({
        ...data,
        'airport': {'direction': 'from_airport'},
      }).toEntity();
      expect(parsed.airport!.direction, AirportDirection.fromAirport);
      expect(parsed.fares.single.minor, 12000);
    },
  );

  test(
    'flight number survives promo and is sent for request and schedule',
    () async {
      final source = MockRideSource();
      final repo = RideRepositoryImpl(source);
      final flightDraft = RideDraft(
        pickup: draft.pickup,
        dropoff: draft.dropoff,
        flightNumber: 'RJ 182',
      ).withPromo('HALF');
      when(() => source.request(any())).thenAnswer((_) async => 'id');
      when(() => source.schedule(any())).thenAnswer((_) async => 'id');
      await repo.requestRide(flightDraft, VehicleType.economy);
      await repo.scheduleRide(flightDraft, VehicleType.comfort);
      for (final payload in [
        verify(() => source.request(captureAny())).captured.single as Map,
        verify(() => source.schedule(captureAny())).captured.single as Map,
      ]) {
        expect(payload['flightNumber'], 'RJ 182');
        expect(payload['promoCode'], 'HALF');
        expect(payload.containsKey('fare'), isFalse);
        expect(payload.containsKey('airport'), isFalse);
      }
    },
  );

  blocTest<AirportCubit, AirportState>(
    'loads airport configuration through its use case',
    build: () {
      final repo = MockAirportConfigRepository();
      when(repo.airportConfig).thenAnswer(
        (_) async => Right(parseAirportConfig(airportJson())),
      );
      return AirportCubit(
        GetAirportConfig(repo),
        CurrentPosition(MockLocation()),
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AirportState(loading: true),
      AirportState(config: parseAirportConfig(airportJson())),
    ],
  );

  test('location failure stays actionable and can retry', () async {
    final repo = MockAirportConfigRepository();
    final location = MockLocation();
    when(repo.airportConfig).thenAnswer(
      (_) async => Right(parseAirportConfig(airportJson())),
    );
    when(location.currentPosition).thenAnswer(
      (_) async => const Left(ServerFailure('offline')),
    );
    final cubit = AirportCubit(
      GetAirportConfig(repo),
      CurrentPosition(location),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(await cubit.pickup(), isNull);
    expect(cubit.state.failure, isA<ServerFailure>());
    when(location.currentPosition).thenAnswer(
      (_) async => const Right(GeoPointValue(31.95, 35.91)),
    );
    expect(await cubit.pickup(), const GeoPointValue(31.95, 35.91));
    expect(cubit.state.failure, isNull);
  });

  test(
    'airport confirmation metadata survives selection, promo and retry',
    () async {
      final repo = MockRouteRepository();
      when(
        () => repo.getFareEstimates(
          origin: draft.pickup.location,
          destination: draft.dropoff.location,
        ),
      ).thenAnswer(
        (_) async => Right(
          FareEstimates(
            route: estimates.route,
            fares: estimates.fares,
            airport: const AirportDetails(
              direction: AirportDirection.toAirport,
            ),
          ),
        ),
      );
      final cubit = RideConfirmCubit(
        GetFareEstimates(repo),
        requestRideStub(),
        draft,
        scheduleRide: scheduleRideStub(),
        validatePromo: promoValidatorStub(),
      );
      addTearDown(cubit.close);
      await cubit.start();
      cubit
        ..select(VehicleType.van)
        ..removePromo();
      await cubit.confirm();
      expect(
        (cubit.state as RideConfirmLoaded).airport!.direction,
        AirportDirection.toAirport,
      );
      expect((cubit.state as RideConfirmLoaded).requestFailure, isNotNull);
    },
  );
}
