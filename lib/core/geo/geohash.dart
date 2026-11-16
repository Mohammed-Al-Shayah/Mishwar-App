/// GeoFire-compatible base32 geohash; midpoint ties go to the lower cell.
String encodeGeohash(double lat, double lng, {int precision = 9}) {
  if (!lat.isFinite || lat < -90 || lat > 90) {
    throw ArgumentError.value(lat, 'lat');
  }
  if (!lng.isFinite || lng < -180 || lng > 180) {
    throw ArgumentError.value(lng, 'lng');
  }
  RangeError.checkValueInInterval(precision, 1, 22, 'precision');
  const alphabet = '0123456789bcdefghjkmnpqrstuvwxyz';
  final low = [-180.0, -90.0];
  final high = [180.0, 90.0];
  final values = [lng, lat];
  final hash = StringBuffer();
  var value = 0;
  for (var bit = 0; bit < precision * 5; bit++) {
    final axis = bit % 2;
    final mid = (low[axis] + high[axis]) / 2;
    value <<= 1;
    if (values[axis] > mid) {
      value++;
      low[axis] = mid;
    } else {
      high[axis] = mid;
    }
    if (bit % 5 == 4) {
      hash.write(alphabet[value]);
      value = 0;
    }
  }
  return hash.toString();
}
