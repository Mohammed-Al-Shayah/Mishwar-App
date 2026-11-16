import 'package:injectable/injectable.dart';

@lazySingleton
class RideTrackingClock {
  DateTime now() => DateTime.now();
}
