import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/geo/trip_motion.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

void main() {
  test('position lerp endpoints and midpoint', () {
    const a = GeoPointValue(31, 35);
    const b = GeoPointValue(33, 37);
    expect(interpolatePoint(a, b, 0), a);
    expect(interpolatePoint(a, b, .5), const GeoPointValue(32, 36));
    expect(interpolatePoint(a, b, 1), b);
  });
  test('bearing crosses north in the shortest direction', () {
    expect(interpolateBearing(350, 10, .5), 0);
    expect(interpolateBearing(10, 350, .5), 0);
    expect(interpolateBearing(350, 10, 1), 10);
    expect(interpolateBearing(10, 350, 1), 350);
    expect(interpolateBearing(90, 180, .5), 135);
  });
}
