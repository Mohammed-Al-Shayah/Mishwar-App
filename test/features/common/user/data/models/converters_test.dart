import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

void main() {
  test('timestamp preserves microsecond instant', () {
    const converter = TimestampConverter();
    final value = DateTime.utc(2026, 1, 2, 3, 4, 5, 6, 7);
    expect(converter.fromJson(converter.toJson(value)), value);
  });
  test('geopoint conversion and equality', () {
    const converter = GeoPointConverter();
    const value = GeoPointValue(-90, 180);
    expect(converter.fromJson(converter.toJson(value)), value);
    expect(converter.toJson(value), const GeoPoint(-90, 180));
  });
  test('invalid coordinates assert', () {
    expect(() => GeoPointValue(91, 0), throwsAssertionError);
    expect(() => GeoPointValue(0, -181), throwsAssertionError);
  });
}
