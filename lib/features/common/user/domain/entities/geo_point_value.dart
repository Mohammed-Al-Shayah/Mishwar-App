import 'package:equatable/equatable.dart';

class GeoPointValue extends Equatable {
  const GeoPointValue(this.lat, this.lng)
    : assert(lat >= -90 && lat <= 90, 'Invalid latitude'),
      assert(lng >= -180 && lng <= 180, 'Invalid longitude');
  final double lat;
  final double lng;
  @override
  List<Object?> get props => [lat, lng];
}
