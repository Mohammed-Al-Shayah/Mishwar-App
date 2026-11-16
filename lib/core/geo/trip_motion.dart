import 'dart:math' as math;
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

GeoPointValue interpolatePoint(
  GeoPointValue from,
  GeoPointValue to,
  double t,
) => GeoPointValue(
  from.lat + (to.lat - from.lat) * t,
  from.lng + (to.lng - from.lng) * t,
);
double interpolateBearing(double from, double to, double t) =>
    (from + ((to - from + 540) % 360 - 180) * t) % 360;
double distanceMeters(GeoPointValue a, GeoPointValue b) {
  const radians = math.pi / 180;
  final dLat = (b.lat - a.lat) * radians;
  final dLng = (b.lng - a.lng) * radians;
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(a.lat * radians) *
          math.cos(b.lat * radians) *
          math.pow(math.sin(dLng / 2), 2);
  return 6371000 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
}
