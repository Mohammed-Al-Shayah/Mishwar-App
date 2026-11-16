import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
part 'place_models.freezed.dart';
part 'place_models.g.dart';

@freezed
abstract class PlaceSuggestionModel with _$PlaceSuggestionModel {
  const factory PlaceSuggestionModel({
    required String placeId,
    required String primaryText,
    required String secondaryText,
  }) = _PlaceSuggestionModel;
  const PlaceSuggestionModel._();
  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionModelFromJson(json);
  PlaceSuggestion toEntity() => PlaceSuggestion(
    placeId: placeId,
    primaryText: primaryText,
    secondaryText: secondaryText,
  );
}

@freezed
abstract class PlaceDetailsModel with _$PlaceDetailsModel {
  const factory PlaceDetailsModel({
    required String placeId,
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) = _PlaceDetailsModel;
  const PlaceDetailsModel._();
  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsModelFromJson(json);
  PlaceDetails toEntity() => PlaceDetails(
    placeId: placeId,
    name: name,
    address: address,
    location: GeoPointValue(lat, lng),
  );
}
