import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/pricing/domain/entities/pricing_table.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/pricing/domain/fare_calculator.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

void main() {
  const calculator = FareCalculator();
  final table = PricingTable.defaults();
  final fixtures =
      jsonDecode(
            File(
              'firebase/functions/test/fixtures/fares.json',
            ).readAsStringSync(),
          )
          as List<dynamic>;
  for (final value in fixtures) {
    final row = value as Map<String, dynamic>;
    test('shared fixture: ${row['name']}', () {
      final type = VehicleType.values.byName(row['vehicleType'] as String);
      final result = calculator.compute(
        rates: table[type],
        distanceMeters: row['distanceMeters'] as num,
        durationSeconds: row['durationSeconds'] as num,
      );
      expect(result.amount, row['expectedFils']);
      expect(
        result.toJodString(),
        ((row['expectedFils'] as int) / 1000).toStringAsFixed(2),
      );
    });
  }
  test('money formatting preserves fils and two decimal display', () {
    for (final (fils, text) in [
      (0, '0.00'),
      (50, '0.05'),
      (3400, '3.40'),
      (10000, '10.00'),
      (3405, '3.41'),
    ]) {
      final money = Money(fils);
      expect(money.amount, fils);
      expect(money.toJodString(), text);
      expect(money, Money(fils));
    }
  });
  test('pricing table is complete and immutable', () {
    expect(table.rates.clear, throwsUnsupportedError);
    expect(() => PricingTable(const {}), throwsArgumentError);
  });
  test('invalid measurements are rejected', () {
    for (final value in [-1, double.nan, double.infinity]) {
      expect(
        () => calculator.compute(
          rates: table[VehicleType.economy],
          distanceMeters: value,
          durationSeconds: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculator.compute(
          rates: table[VehicleType.economy],
          distanceMeters: 0,
          durationSeconds: value,
        ),
        throwsArgumentError,
      );
    }
  });
  test('configured rates and exact minimum rounding', () {
    const rates = VehicleRates(base: 0, perKm: 1000, perMin: 0, minimum: 1025);
    expect(
      calculator
          .compute(rates: rates, distanceMeters: 0, durationSeconds: 0)
          .amount,
      1050,
    );
    expect(
      calculator
          .compute(rates: rates, distanceMeters: 1075, durationSeconds: 0)
          .amount,
      1100,
    );
  });
}
