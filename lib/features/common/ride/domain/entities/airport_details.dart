import 'package:equatable/equatable.dart';

enum AirportDirection { toAirport, fromAirport }

class AirportDetails extends Equatable {
  const AirportDetails({
    required this.direction,
    this.flightNumber,
    this.fixedFare = true,
  });
  final AirportDirection direction;
  final String? flightNumber;
  final bool fixedFare;
  @override
  List<Object?> get props => [direction, flightNumber, fixedFare];
}

String? normalizeFlightNumber(String input) {
  final value = input.trim().toUpperCase();
  return RegExp(r'^[A-Z0-9]{2}\s?\d{1,4}[A-Z]?$').hasMatch(value)
      ? value
      : null;
}
