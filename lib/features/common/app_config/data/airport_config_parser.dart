import 'dart:convert';

import 'package:mishwar/features/common/app_config/domain/airport_config.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

// Only geometry and pickup names enter the client.
// Fare calculation stays on the server.
AirportConfig? parseAirportConfig(Map<String, dynamic>? data) {
  final airport = data?['airport'] as Map<String, dynamic>?;
  if (airport?['zone'] == null) return null;
  final rawZone = airport!['zone'];
  final zone =
      (rawZone is String ? jsonDecode(rawZone) : rawZone)
          as Map<String, dynamic>;
  if (zone['type'] != 'Polygon') throw const FormatException('Invalid zone');
  final ring = (zone['coordinates'] as List<dynamic>).first as List<dynamic>;
  if (ring.length < 4) throw const FormatException('Invalid zone');
  var area = 0.0;
  var x = 0.0;
  var y = 0.0;
  for (var i = 0; i < ring.length - 1; i++) {
    final a = ring[i] as List<dynamic>;
    final b = ring[i + 1] as List<dynamic>;
    final ax = (a[0] as num).toDouble();
    final ay = (a[1] as num).toDouble();
    final bx = (b[0] as num).toDouble();
    final by = (b[1] as num).toDouble();
    final cross = ax * by - bx * ay;
    area += cross;
    x += (ax + bx) * cross;
    y += (ay + by) * cross;
  }
  if (area.abs() < 1e-12) throw const FormatException('Empty zone');
  return AirportConfig(
    centroid: GeoPointValue(y / (3 * area), x / (3 * area)),
    pickupPoints: [
      for (final raw in airport['pickupPoints'] as List<dynamic>? ?? [])
        if (raw case final Map<String, dynamic> p)
          RideStop(
            name: p['name'] as String,
            address: p['name'] as String,
            location: GeoPointValue(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ),
          ),
    ],
  );
}
