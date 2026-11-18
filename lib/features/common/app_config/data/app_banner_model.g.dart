// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppBannerModel _$AppBannerModelFromJson(Map<String, dynamic> json) =>
    _AppBannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      action: json['action'] as String,
      order: (json['order'] as num).toInt(),
      validUntil: const TimestampConverter().fromJson(
        json['validUntil'] as Timestamp,
      ),
      active: json['active'] as bool,
      promoCode: json['promoCode'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AppBannerModelToJson(_AppBannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'action': instance.action,
      'order': instance.order,
      'validUntil': const TimestampConverter().toJson(instance.validUntil),
      'active': instance.active,
      'promoCode': instance.promoCode,
      'url': instance.url,
    };
