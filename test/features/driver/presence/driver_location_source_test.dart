import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishwar/features/driver/presence/data/driver_location_source.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);
  final source = DriverLocationSource();
  test(
    'Android stream uses five second foreground service '
    'with localized notification',
    () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final settings =
          source.settings(
                notificationTitle: 'Localized title',
                notificationText: 'Localized text',
              )
              as AndroidSettings;
      expect(settings.accuracy, LocationAccuracy.high);
      expect(settings.distanceFilter, 0);
      expect(settings.intervalDuration, const Duration(seconds: 5));
      expect(
        settings.foregroundNotificationConfig!.notificationTitle,
        'Localized title',
      );
      expect(
        settings.foregroundNotificationConfig!.notificationText,
        'Localized text',
      );
      expect(settings.foregroundNotificationConfig!.enableWakeLock, isTrue);
    },
  );
  test(
    'iOS stream uses automotive background updates '
    'with visible indicator',
    () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final settings =
          source.settings(notificationTitle: 'Title', notificationText: 'Text')
              as AppleSettings;
      expect(settings.activityType, ActivityType.automotiveNavigation);
      expect(settings.allowBackgroundLocationUpdates, isTrue);
      expect(settings.showBackgroundLocationIndicator, isTrue);
      expect(settings.pauseLocationUpdatesAutomatically, isFalse);
      expect(settings.distanceFilter, 0);
    },
  );
}
