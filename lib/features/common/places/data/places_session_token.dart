import 'package:uuid/uuid.dart';

/// Create once for each autocomplete session; renew after selection or abandon.
class PlacesSessionToken {
  PlacesSessionToken() : _value = const Uuid().v4();
  String _value;
  String get value => _value;
  String renew() => _value = const Uuid().v4();
}
