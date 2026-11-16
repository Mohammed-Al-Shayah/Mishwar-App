import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/features/common/ride/data/models/driver_live_location_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mocktail/mocktail.dart';
import 'ride_data_test.dart' show MockSource;

void main() {
  test(
    'live document maps point, heading and server time through use case',
    () async {
      final time = DateTime.utc(2026, 11, 16);
      final model = DriverLiveLocationModel.fromJson({
        'geopoint': const GeoPoint(31.95, 35.91),
        'updatedAt': Timestamp.fromDate(time),
        'heading': 90,
      });
      final source = MockSource();
      when(
        () => source.watchDriverLocation('ride'),
      ).thenAnswer((_) => Stream.value(model));
      final entity = model.toEntity();
      expect(entity.point, const GeoPointValue(31.95, 35.91));
      expect(entity.heading, 90);
      expect(entity.updatedAt, time);
      expect(
        DriverLiveLocationModel.fromJson(model.toJson()).toEntity(),
        entity,
      );
      expect(model.copyWith(heading: null).toEntity().heading, isNull);
      expect(
        await WatchDriverLocation(RideRepositoryImpl(source))('ride').first,
        Right<dynamic, dynamic>(entity),
      );
    },
  );
  test(
    'stream errors map to Failure and invalid bearings are rejected',
    () async {
      final source = MockSource();
      when(
        () => source.watchDriverLocation('ride'),
      ).thenAnswer((_) => Stream.error(StateError('offline')));
      final result = await WatchDriverLocation(RideRepositoryImpl(source))(
        'ride',
      ).first;
      expect(result.isLeft(), isTrue);
      expect(
        () => DriverLiveLocationModel(
          point: const GeoPointValue(0, 0),
          updatedAt: DateTime.utc(2026),
          heading: 361,
        ).toEntity(),
        throwsFormatException,
      );
    },
  );
}
