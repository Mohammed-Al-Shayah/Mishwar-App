import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/geo/polyline.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

void main() {
  test('Google documented sample, negative deltas and three points', () {
    expect(decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@'), const [
      GeoPointValue(38.5, -120.2),
      GeoPointValue(40.7, -120.95),
      GeoPointValue(43.252, -126.453),
    ]);
  });
  test('empty, zero and repeated coordinates', () {
    expect(decodePolyline(''), isEmpty);
    expect(decodePolyline('????'), const [
      GeoPointValue(0, 0),
      GeoPointValue(0, 0),
    ]);
  });
  test('rejects incomplete and invalid encodings', () {
    for (final value in ['_', '?', '!', '~~~~~~~~']) {
      expect(() => decodePolyline(value), throwsFormatException);
    }
  });
}
