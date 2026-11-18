import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class PickupSuggestion extends Equatable {
  const PickupSuggestion({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceMeters,
  });
  final String id;
  final String name;
  final GeoPointValue location;
  final double distanceMeters;
  @override
  List<Object> get props => [id, name, location, distanceMeters];
}

abstract class PickupRepository {
  Future<Either<Failure, RideStop>> reverse(GeoPointValue point, String lang);
  Future<Either<Failure, List<PickupSuggestion>>> suggestions(
    GeoPointValue point,
  );
}

@lazySingleton
class ReverseGeocode {
  const ReverseGeocode(this._repository);
  final PickupRepository _repository;
  Future<Either<Failure, RideStop>> call(GeoPointValue point, String lang) =>
      _repository.reverse(point, lang);
}

@lazySingleton
class GetPickupSuggestions {
  const GetPickupSuggestions(this._repository);
  final PickupRepository _repository;
  Future<Either<Failure, List<PickupSuggestion>>> call(GeoPointValue point) =>
      _repository.suggestions(point);
}
