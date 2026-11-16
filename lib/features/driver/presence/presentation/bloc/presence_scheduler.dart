import 'dart:async';
import 'package:injectable/injectable.dart';

/// Injectable clock and periodic timer; tests can supply fake time.
@lazySingleton
class PresenceScheduler {
  DateTime now() => DateTime.now();
  Timer every(Duration duration, void Function() callback) =>
      Timer.periodic(duration, (_) => callback());
}
