import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class PlaceDetails extends Equatable {
  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
  });
  final String placeId;
  final String name;
  final String address;
  final GeoPointValue location;
  @override
  List<Object> get props => [placeId, name, address, location];
}
