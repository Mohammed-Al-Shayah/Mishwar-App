import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';

/// Server-owned documents; timestamps are decoded by the data layer.
class ManagementData extends Equatable {
  ManagementData({
    Map<String, Object?> settings = const {},
    List<Map<String, Object?>> promos = const [],
    Map<String, DateTime> edits = const {},
  }) : settings = Map.unmodifiable(settings),
       promos = List.unmodifiable(
         promos.map(Map<String, Object?>.unmodifiable),
       ),
       edits = Map.unmodifiable(edits);
  final Map<String, Object?> settings;
  final List<Map<String, Object?>> promos;
  final Map<String, DateTime> edits;
  @override
  List<Object?> get props => [settings, promos, edits];
}

// Repository boundary keeps Firestore out of presentation.
// ignore: one_member_abstracts
abstract interface class ManagementRepository {
  Future<Either<Failure, ManagementData>> load();
}

@lazySingleton
class LoadManagement {
  const LoadManagement(this._repository);
  final ManagementRepository _repository;
  Future<Either<Failure, ManagementData>> call() => _repository.load();
}

/// Same integer-fils, downward 50-fils rounding as evaluatePromo on the server.
int promoDiscountFils({
  required int fareFils,
  required String type,
  required double value,
  double? maxDiscount,
}) {
  final parts = value.toString().toLowerCase().split('e');
  final decimal = parts.first.split('.');
  final fraction = decimal.length == 2 ? decimal.last : '';
  final scale =
      fraction.length - (parts.length == 2 ? int.parse(parts.last) : 0);
  final numerator = BigInt.parse('${decimal.first}$fraction');
  final raw = type == 'percent'
      ? (scale >= 0
                ? BigInt.from(fareFils) *
                      numerator ~/
                      (BigInt.from(100) * BigInt.from(10).pow(scale))
                : BigInt.from(fareFils) *
                      numerator *
                      BigInt.from(10).pow(-scale) ~/
                      BigInt.from(100))
            .toInt()
      : (value * 1000).round();
  final cap = type == 'percent' && maxDiscount != null
      ? (maxDiscount * 1000).round()
      : fareFils;
  return raw.clamp(0, cap.clamp(0, fareFils)) ~/ 50 * 50;
}

const settingsBounds = <String, Map<String, (double, double, bool)>>{
  'cancellationFee': {
    'amount': (0, 20, false),
    'afterSeconds': (0, 1800, true),
  },
  'waitingFee': {'freeMinutes': (0, 30, true), 'perMinute': (0, 2, false)},
  'scheduling': {
    'minLeadMinutes': (15, 720, true),
    'maxDaysAhead': (1, 60, true),
    'dispatchBeforeMinutes': (5, 60, true),
  },
  'fixedFares': {
    'economy': (1, 100, false),
    'comfort': (1, 100, false),
    'van': (1, 100, false),
  },
};
bool validNumber(String text, double min, double max, {bool integer = false}) {
  final value = double.tryParse(text.trim());
  return value != null &&
      value.isFinite &&
      value >= min &&
      value <= max &&
      (!integer || int.tryParse(text.trim()) != null);
}
