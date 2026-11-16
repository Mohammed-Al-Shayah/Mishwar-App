import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';

@lazySingleton
class FareCalculator {
  const FareCalculator();
  Money compute({
    required VehicleRates rates,
    required num distanceMeters,
    required num durationSeconds,
  }) {
    if ([
      rates.base,
      rates.perKm,
      rates.perMin,
      rates.minimum,
    ].any((value) => value < 0)) {
      throw ArgumentError('Rates must be nonnegative');
    }
    final (distance, distanceScale) = _decimal(distanceMeters);
    final (duration, durationScale) = _decimal(durationSeconds);
    final thousand = BigInt.from(1000);
    final sixty = BigInt.from(60);
    final denominator = distanceScale * durationScale * thousand * sixty;
    final total =
        BigInt.from(rates.base) * denominator +
        BigInt.from(rates.perKm) * distance * durationScale * sixty +
        BigInt.from(rates.perMin) * duration * distanceScale * thousand;
    final minimum = BigInt.from(rates.minimum) * denominator;
    final fare = total > minimum ? total : minimum;
    final rounded =
        ((fare * BigInt.two + BigInt.from(50) * denominator) ~/
            (BigInt.from(100) * denominator)) *
        BigInt.from(50);
    if (rounded > BigInt.from(9007199254740991)) {
      throw ArgumentError('Fare is too large');
    }
    return Money(rounded.toInt());
  }

  // Parse decimal inputs before arithmetic to preserve exact half-up ties.
  (BigInt, BigInt) _decimal(num value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be finite and nonnegative',
      );
    }
    final parts = value.toString().toLowerCase().split('e');
    final coefficient = parts.first.split('.');
    final fraction = coefficient.length == 2 ? coefficient[1] : '';
    final scale =
        fraction.length - (parts.length == 2 ? int.parse(parts[1]) : 0);
    final numerator = BigInt.parse(coefficient.first + fraction);
    return scale >= 0
        ? (numerator, BigInt.from(10).pow(scale))
        : (numerator * BigInt.from(10).pow(-scale), BigInt.one);
  }
}
