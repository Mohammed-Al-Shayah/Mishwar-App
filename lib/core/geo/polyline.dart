import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

/// Decodes Google's signed, delta-encoded coordinates at precision 5.
List<GeoPointValue> decodePolyline(String encoded) {
  var index = 0;
  var lat = 0;
  var lng = 0;
  int component() {
    var value = 0;
    var shift = 0;
    while (true) {
      if (index >= encoded.length || shift > 30) {
        throw const FormatException('Invalid encoded polyline');
      }
      final byte = encoded.codeUnitAt(index++) - 63;
      if (byte < 0 || byte > 63) {
        throw const FormatException('Invalid encoded polyline character');
      }
      value |= (byte & 31) << shift;
      if (byte < 32) break;
      shift += 5;
    }
    return value.isOdd ? ~(value >> 1) : value >> 1;
  }

  final points = <GeoPointValue>[];
  while (index < encoded.length) {
    lat += component();
    lng += component();
    points.add(GeoPointValue(lat / 1e5, lng / 1e5));
  }
  return points;
}
