import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';

part 'promo_quote_model.freezed.dart';
part 'promo_quote_model.g.dart';

@freezed
abstract class PromoQuoteModel with _$PromoQuoteModel {
  const factory PromoQuoteModel({
    required String code,
    required double discount,
    required double fareBefore,
    required double fareAfter,
    @Default('JOD') String currency,
  }) = _PromoQuoteModel;
  const PromoQuoteModel._();
  factory PromoQuoteModel.fromJson(Map<String, dynamic> json) =>
      _$PromoQuoteModelFromJson(json);
  PromoQuote toEntity() {
    int minor(double value) {
      if (!value.isFinite || value < 0) {
        throw const FormatException('Invalid promo quote');
      }
      return (value * Money.scale(currency)).round();
    }

    return PromoQuote(
      code: code,
      currency: currency,
      discountMinor: minor(discount),
      fareBeforeMinor: minor(fareBefore),
      fareAfterMinor: minor(fareAfter),
    );
  }
}
