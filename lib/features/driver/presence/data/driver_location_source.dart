import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/driver/presence/domain/driver_fix.dart';

@lazySingleton
class DriverLocationSource {
  LocationSettings settings({
    required String notificationTitle,
    required String notificationText,
  }) {
    if (kIsWeb) return const LocationSettings(accuracy: LocationAccuracy.high);
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.high,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          enableWakeLock: true,
        ),
      ),
      TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        // Defaults already allow background updates and never auto-pause.
        showBackgroundLocationIndicator: true,
      ),
      _ => const LocationSettings(accuracy: LocationAccuracy.high),
    };
  }

  Stream<DriverFix> watch({
    required String notificationTitle,
    required String notificationText,
  }) =>
      Geolocator.getPositionStream(
        locationSettings: settings(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
        ),
      ).map(
        (p) => DriverFix(
          GeoPointValue(p.latitude, p.longitude),
          heading: p.heading.isFinite && p.heading >= 0 && p.heading <= 360
              ? p.heading
              : null,
        ),
      );
}
