import 'package:equatable/equatable.dart';

class PromoQuote extends Equatable {
  const PromoQuote({
    required this.code,
    required this.discountMinor,
    required this.fareBeforeMinor,
    required this.fareAfterMinor,
    this.currency = 'JOD',
  });
  final String code;
  final String currency;
  final int discountMinor;
  final int fareBeforeMinor;
  final int fareAfterMinor;
  @override
  List<Object> get props => [
    currency,
    code,
    discountMinor,
    fareBeforeMinor,
    fareAfterMinor,
  ];
}
