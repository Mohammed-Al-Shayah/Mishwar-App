// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PromoQuoteModel _$PromoQuoteModelFromJson(Map<String, dynamic> json) =>
    _PromoQuoteModel(
      code: json['code'] as String,
      discount: (json['discount'] as num).toDouble(),
      fareBefore: (json['fareBefore'] as num).toDouble(),
      fareAfter: (json['fareAfter'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'JOD',
    );

Map<String, dynamic> _$PromoQuoteModelToJson(_PromoQuoteModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'discount': instance.discount,
      'fareBefore': instance.fareBefore,
      'fareAfter': instance.fareAfter,
      'currency': instance.currency,
    };
