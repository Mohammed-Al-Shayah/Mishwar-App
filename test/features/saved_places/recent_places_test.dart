import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/ride_mocks.dart';

class Cursor extends HistoryCursor {}

RideEntity ride(
  String id,
  String name, {
  RideStatus status = RideStatus.completed,
}) => RideEntity(
  id: id,
  riderId: 'u',
  status: status,
  vehicleType: VehicleType.economy,
  pickup: const RideStop(
    name: 'Pickup',
    address: '',
    location: GeoPointValue(31, 35),
  ),
  dropoff: RideStop(
    name: name,
    address: '$name street',
    location: const GeoPointValue(32, 35),
  ),
  fareEstimatedMinor: 100,
  createdAt: DateTime.utc(2026),
);

void main() {
  test(
    'recent places page past cancelled rides to find two destinations',
    () async {
      final repo = MockRideRepository();
      final cursor = Cursor();
      when(
        () => repo.history(party: RideParty.rider, uid: 'u', limit: 10),
      ).thenAnswer(
        (_) async => Right(
          RideHistoryPage(
            items: [ride('cancelled', 'Mall', status: RideStatus.cancelled)],
            next: cursor,
          ),
        ),
      );
      when(
        () => repo.history(
          party: RideParty.rider,
          uid: 'u',
          after: cursor,
          limit: 10,
        ),
      ).thenAnswer(
        (_) async => Right(
          RideHistoryPage(
            items: [ride('one', 'Park'), ride('two', 'Work')],
          ),
        ),
      );
      final cubit = RecentPlacesCubit(GetRideHistory(repo));
      await cubit.load('u');
      expect(cubit.state.map((p) => p.name), ['Park', 'Work']);
      await cubit.close();
    },
  );
  test(
    'recent places filter, dedupe, cap and clear on failure',
    () async {
      final repo = MockRideRepository();
      when(
        () => repo.history(party: RideParty.rider, uid: 'u', limit: 10),
      ).thenAnswer(
        (_) async => Right(
          RideHistoryPage(
            items: [
              ride('cancelled', 'Mall', status: RideStatus.cancelled),
              ride('new', 'Park'),
              ride('duplicate', ' park '),
              ride('work', 'Work'),
              ride('third', 'Cafe'),
            ],
          ),
        ),
      );
      final cubit = RecentPlacesCubit(GetRideHistory(repo));
      await cubit.load('u');
      expect(cubit.state.map((p) => p.placeId), ['recent-new', 'recent-work']);
      expect(cubit.state.first.address, 'Park street');
      when(
        () => repo.history(party: RideParty.rider, uid: 'u', limit: 10),
      ).thenAnswer((_) async => const Left(ServerFailure('offline')));
      await cubit.load('u');
      expect(cubit.state, isEmpty);
      await cubit.close();
    },
  );
}
