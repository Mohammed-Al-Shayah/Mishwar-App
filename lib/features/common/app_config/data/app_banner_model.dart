import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';

part 'app_banner_model.freezed.dart';
part 'app_banner_model.g.dart';

@freezed
abstract class AppBannerModel with _$AppBannerModel {
  const factory AppBannerModel({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String action,
    required int order,
    @TimestampConverter() required DateTime validUntil,
    required bool active,
    String? promoCode,
    String? url,
  }) = _AppBannerModel;
  const AppBannerModel._();
  factory AppBannerModel.fromJson(Map<String, dynamic> json) =>
      _$AppBannerModelFromJson(json);
  AppBanner toEntity() => AppBanner(
    id: id,
    title: title,
    subtitle: subtitle,
    imageUrl: imageUrl,
    action: switch (action) {
      'open_search' => BannerAction.openSearch,
      'open_promo' => BannerAction.openPromo,
      'url' => BannerAction.url,
      _ => throw const FormatException('banner-action'),
    },
    order: order,
    validUntil: validUntil,
    active: active,
    promoCode: promoCode,
    url: url,
  );
}
