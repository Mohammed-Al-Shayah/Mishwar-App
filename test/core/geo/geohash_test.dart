import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/geo/geohash.dart';

void main() {
  final fixtures =
      jsonDecode(
            File(
              'firebase/functions/test/fixtures/geohash.json',
            ).readAsStringSync(),
          )
          as List<dynamic>;
  for (final raw in fixtures) {
    final c = raw as Map<String, dynamic>;
    test('shared fixture $c', () {
      expect(
        encodeGeohash(
          (c['lat'] as num).toDouble(),
          (c['lng'] as num).toDouble(),
          precision: c['precision'] as int,
        ),
        c['hash'],
      );
    });
  }
  test('default precision and invalid inputs', () {
    expect(encodeGeohash(57.64911, 10.40744), 'u4pruydqq');
    for (final p in [0, 23]) {
      expect(() => encodeGeohash(0, 0, precision: p), throwsRangeError);
    }
    expect(() => encodeGeohash(double.nan, 0), throwsArgumentError);
    expect(() => encodeGeohash(91, 0), throwsArgumentError);
    expect(() => encodeGeohash(0, 181), throwsArgumentError);
  });
}
