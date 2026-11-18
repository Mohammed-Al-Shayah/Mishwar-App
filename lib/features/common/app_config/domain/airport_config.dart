import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class AirportConfig extends Equatable {
  AirportConfig({required this.centroid, required List<RideStop> pickupPoints})
    : pickupPoints = List.unmodifiable(pickupPoints);
  final GeoPointValue centroid;
  final List<RideStop> pickupPoints;
  @override
  List<Object?> get props => [centroid, pickupPoints];
}
