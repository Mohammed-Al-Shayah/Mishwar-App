import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GeolocatorClient {
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
  Future<Position> currentPosition() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    ),
  );
  Stream<Position> watchPosition() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
  Future<bool> openAppSettings() async {
    if (kIsWeb) throw Exception('settings-unavailable');
    return Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    if (kIsWeb) throw Exception('settings-unavailable');
    return Geolocator.openLocationSettings();
  }
}
