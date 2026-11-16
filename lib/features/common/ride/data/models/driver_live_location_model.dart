import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/domain/entities/driver_live_location.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
part 'driver_live_location_model.freezed.dart';
part 'driver_live_location_model.g.dart';

@freezed
abstract class DriverLiveLocationModel with _$DriverLiveLocationModel {
  const factory DriverLiveLocationModel({
    @JsonKey(name: 'geopoint')
    @GeoPointConverter()
    required GeoPointValue point,
    @TimestampConverter() required DateTime updatedAt,
    double? heading,
  }) = _DriverLiveLocationModel;
  const DriverLiveLocationModel._();
  factory DriverLiveLocationModel.fromJson(Map<String, dynamic> json) =>
      _$DriverLiveLocationModelFromJson(json);
  DriverLiveLocation toEntity() {
    final bearing = heading;
    if (bearing != null &&
        (!bearing.isFinite || bearing < 0 || bearing > 360)) {
      throw const FormatException('Invalid heading');
    }
    return DriverLiveLocation(
      point: point,
      heading: heading,
      updatedAt: updatedAt,
    );
  }
}
