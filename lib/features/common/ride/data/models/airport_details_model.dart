import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';

part 'airport_details_model.freezed.dart';
part 'airport_details_model.g.dart';

class AirportDirectionConverter
    implements JsonConverter<AirportDirection, String> {
  const AirportDirectionConverter();
  @override
  AirportDirection fromJson(String value) => switch (value) {
    'to_airport' => AirportDirection.toAirport,
    'from_airport' => AirportDirection.fromAirport,
    _ => throw const FormatException('Invalid airport direction'),
  };
  @override
  String toJson(AirportDirection value) =>
      value == AirportDirection.toAirport ? 'to_airport' : 'from_airport';
}

@freezed
abstract class AirportDetailsModel with _$AirportDetailsModel {
  const factory AirportDetailsModel({
    @AirportDirectionConverter() required AirportDirection direction,
    String? flightNumber,
    @Default(true) bool fixedFare,
  }) = _AirportDetailsModel;
  const AirportDetailsModel._();
  factory AirportDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$AirportDetailsModelFromJson(json);
  AirportDetails toEntity() => AirportDetails(
    direction: direction,
    flightNumber: flightNumber,
    fixedFare: fixedFare,
  );
}
