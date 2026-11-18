import 'package:equatable/equatable.dart';

enum BannerAction { openSearch, openPromo, url }

class AppBanner extends Equatable {
  const AppBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.action,
    required this.order,
    required this.validUntil,
    required this.active,
    this.promoCode,
    this.url,
  });
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final BannerAction action;
  final int order;
  final DateTime validUntil;
  final bool active;
  final String? promoCode;
  final String? url;
  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    action,
    order,
    validUntil,
    active,
    promoCode,
    url,
  ];
}
