import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/data/datasources/places_remote_data_source.dart';
import 'package:mishwar/features/common/places/data/repositories/places_repository_impl.dart';
import 'package:mishwar/features/common/places/domain/places_session_token.dart';
import 'package:mishwar/features/common/route/data/datasources/route_remote_data_source.dart';
import 'package:mishwar/features/common/route/data/repositories/route_repository_impl.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockCallable extends Mock implements HttpsCallable {}

class MockResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  late MockFunctions functions;
  late MockCallable callable;
  late PlacesRepositoryImpl places;
  late RouteRepositoryImpl routes;
  const point = GeoPointValue(31, 35);
  setUp(() {
    functions = MockFunctions();
    callable = MockCallable();
    when(() => functions.httpsCallable(any())).thenReturn(callable);
    places = PlacesRepositoryImpl(PlacesRemoteDataSource(functions));
    routes = RouteRepositoryImpl(RouteRemoteDataSource(functions));
  });
  void response(Map<String, dynamic> data) {
    final result = MockResult();
    when(() => result.data).thenReturn(data);
    when(
      () => callable.call<Map<String, dynamic>>(
        any<Map<String, dynamic>>(),
      ),
    ).thenAnswer((_) async => result);
  }

  test('autocomplete maps suggestions and sends bias and session', () async {
    response({
      'suggestions': [
        {'placeId': 'id', 'primaryText': 'Main', 'secondaryText': 'Other'},
      ],
    });
    final result = await places.search(
      input: 'a',
      sessionToken: 'session',
      bias: point,
      lang: 'en',
    );
    expect(result.getOrElse((_) => []).single.primaryText, 'Main');
    verify(() => functions.httpsCallable('placesAutocomplete')).called(1);
    verify(
      () => callable.call<Map<String, dynamic>>({
        'input': 'a',
        'sessionToken': 'session',
        'lat': 31.0,
        'lng': 35.0,
        'lang': 'en',
      }),
    ).called(1);
  });
  test('details map location', () async {
    response({
      'placeId': 'id',
      'name': 'Name',
      'address': 'Address',
      'lat': 31,
      'lng': 35,
    });
    final result = await places.details(placeId: 'id', sessionToken: 'session');
    expect(result.toNullable()!.location, point);
    verify(() => functions.httpsCallable('placeDetails')).called(1);
  });
  test('fare estimates map route and JOD to fils', () async {
    response({
      'route': {
        'polyline': 'abc',
        'distanceMeters': 5000,
        'durationSeconds': 600,
      },
      'fares': [
        {'vehicleType': 'economy', 'amount': 3.4, 'currency': 'JOD'},
      ],
    });
    final result = await routes.getFareEstimates(
      origin: point,
      destination: point,
    );
    expect(result.toNullable()!.route.durationSeconds, 600);
    expect(result.toNullable()!.fares.single.fils, 3400);
    expect(result.toNullable()!.fares.single.vehicleType, VehicleType.economy);
    verify(() => functions.httpsCallable('getFareEstimates')).called(1);
  });
  for (final (code, failure) in <(String, Failure)>[
    ('invalid-argument', const ValidationFailure('invalid-argument')),
    ('unavailable', const NetworkFailure('unavailable')),
    ('deadline-exceeded', const NetworkFailure('unavailable')),
    ('internal', const ServerFailure('internal')),
    ('unauthenticated', const ServerFailure('unauthenticated')),
  ]) {
    test('all repository methods map $code', () async {
      when(
        () => callable.call<Map<String, dynamic>>(
          any<Map<String, dynamic>>(),
        ),
      ).thenThrow(
        FirebaseFunctionsException(code: code, message: 'private message'),
      );
      expect(
        (await places.search(
          input: 'a',
          sessionToken: 's',
        )).getLeft().toNullable(),
        failure,
      );
      expect(
        (await places.details(
          placeId: 'a',
          sessionToken: 's',
        )).getLeft().toNullable(),
        failure,
      );
      expect(
        (await routes.getFareEstimates(
          origin: point,
          destination: point,
        )).getLeft().toNullable(),
        failure,
      );
    });
  }
  test('malformed response becomes server failure', () async {
    response({'route': <String, dynamic>{}});
    expect(
      (await routes.getFareEstimates(
        origin: point,
        destination: point,
      )).isLeft(),
      isTrue,
    );
  });
  test('session token is stable until renewed and UUID v4', () {
    final session = PlacesSessionToken();
    final first = session.value;
    expect(
      first,
      matches(
        RegExp(
          '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(session.value, first);
    expect(session.renew(), isNot(first));
  });
}
