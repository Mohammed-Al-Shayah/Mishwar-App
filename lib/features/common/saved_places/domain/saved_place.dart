import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

enum SavedPlaceLabel { home, work, other }

class SavedPlace extends Equatable {
  const SavedPlace({
    required this.id,
    required this.label,
    required this.name,
    required this.address,
    required this.location,
    this.updatedAt,
  });
  final String id;
  final SavedPlaceLabel label;
  final String name;
  final String address;
  final GeoPointValue location;
  final DateTime? updatedAt;
  PlaceDetails get details => PlaceDetails(
    placeId: id,
    name: name,
    address: address,
    location: location,
  );
  @override
  List<Object?> get props => [id, label, name, address, location, updatedAt];
}
