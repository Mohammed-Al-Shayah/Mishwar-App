import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/location/data/datasources/geolocator_client.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';

@lazySingleton
class LocationDataSource {
  const LocationDataSource(this._client);
  final GeolocatorClient _client;
  Future<LocationPermissionStatus> permission({bool request = false}) async {
    if (!await _client.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    final permission = await (request
        ? _client.requestPermission()
        : _client.checkPermission());
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionStatus.granted,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      _ => LocationPermissionStatus.denied,
    };
  }

  Future<Position> currentPosition() =>
      _client.currentPosition().timeout(const Duration(seconds: 10));
  Stream<Position> watchPosition() => _client.watchPosition();
  Future<void> openAppSettings() async {
    await _client.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await _client.openLocationSettings();
  }
}
