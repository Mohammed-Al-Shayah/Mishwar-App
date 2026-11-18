import 'package:equatable/equatable.dart';

class PromoQuote extends Equatable {
  const PromoQuote({
    required this.code,
    required this.discountFils,
    required this.fareBeforeFils,
    required this.fareAfterFils,
  });
  final String code;
  final int discountFils;
  final int fareBeforeFils;
  final int fareAfterFils;
  @override
  List<Object> get props => [code, discountFils, fareBeforeFils, fareAfterFils];
}
