import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

part 'saved_place_model.freezed.dart';
part 'saved_place_model.g.dart';

@freezed
abstract class SavedPlaceModel with _$SavedPlaceModel {
  const factory SavedPlaceModel({
    @JsonKey(includeToJson: false) required String id,
    required SavedPlaceLabel label,
    required String name,
    required String address,
    @GeoPointConverter() required GeoPointValue geopoint,
    @TimestampConverter() DateTime? updatedAt,
  }) = _SavedPlaceModel;
  const SavedPlaceModel._();
  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$SavedPlaceModelFromJson(json);
  SavedPlace toEntity() => SavedPlace(
    id: id,
    label: label,
    name: name,
    address: address,
    location: geopoint,
    updatedAt: updatedAt,
  );
}
