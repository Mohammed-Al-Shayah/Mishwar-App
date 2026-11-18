import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/pickup/domain/pickup_repository.dart';

part 'pickup_models.freezed.dart';
part 'pickup_models.g.dart';

@freezed
abstract class PickupAddressModel with _$PickupAddressModel {
  const factory PickupAddressModel({
    required String name,
    required String address,
  }) = _PickupAddressModel;
  const PickupAddressModel._();
  factory PickupAddressModel.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressModelFromJson(json);
  RideStop toEntity(GeoPointValue point) =>
      RideStop(name: name, address: address, location: point);
}

@freezed
abstract class PickupSuggestionModel with _$PickupSuggestionModel {
  const factory PickupSuggestionModel({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required double distanceMeters,
  }) = _PickupSuggestionModel;
  const PickupSuggestionModel._();
  factory PickupSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$PickupSuggestionModelFromJson(json);
  PickupSuggestion toEntity() => PickupSuggestion(
    id: id,
    name: name,
    location: GeoPointValue(lat, lng),
    distanceMeters: distanceMeters,
  );
}
