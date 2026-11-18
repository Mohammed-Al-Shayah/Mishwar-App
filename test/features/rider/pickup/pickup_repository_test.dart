import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/rider/pickup/data/pickup_models.dart';
import 'package:mishwar/features/rider/pickup/data/pickup_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import 'pickup_confirm_cubit_test.dart' show point;

class MockPickupSource extends Mock implements PickupRemoteDataSource {}

void main() {
  test(
    'callable address and suggestion models map to domain coordinates',
    () async {
      final source = MockPickupSource();
      final repository = PickupRepositoryImpl(source);
      when(() => source.reverse(point, 'en')).thenAnswer(
        (_) async => PickupAddressModel.fromJson({
          'name': 'Street 12',
          'address': 'Full address',
        }),
      );
      when(() => source.suggestions(point)).thenAnswer(
        (_) async => [
          PickupSuggestionModel.fromJson({
            'id': 'parking',
            'name': 'Parking',
            'lat': point.lat,
            'lng': point.lng,
            'distanceMeters': 10,
          }),
        ],
      );
      final stop = (await repository.reverse(
        point,
        'en',
      )).getOrElse((_) => throw StateError('unexpected failure'));
      expect(stop.name, 'Street 12');
      expect(stop.address, 'Full address');
      expect(stop.location, point);
      final suggestions = (await repository.suggestions(
        point,
      )).getOrElse((_) => throw StateError('unexpected failure'));
      expect(suggestions.single.location, point);
      expect(suggestions.single.distanceMeters, 10);
      expect(suggestions.clear, throwsUnsupportedError);
    },
  );
  test('callable failures cross the data boundary as Failure', () async {
    final source = MockPickupSource();
    final repository = PickupRepositoryImpl(source);
    when(() => source.reverse(point, 'ar')).thenThrow(
      FirebaseFunctionsException(code: 'unavailable', message: 'private'),
    );
    when(() => source.suggestions(point)).thenThrow(StateError('bad response'));
    expect(
      await repository.reverse(point, 'ar'),
      isA<Left<Failure, dynamic>>(),
    );
    expect(await repository.suggestions(point), isA<Left<Failure, dynamic>>());
  });
}
