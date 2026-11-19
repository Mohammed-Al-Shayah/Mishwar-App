import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

class PromoDiscountRow extends StatelessWidget {
  const PromoDiscountRow({required this.ride, super.key});
  final RideEntity ride;
  @override
  Widget build(BuildContext context) =>
      ride.promoApplied != true || ride.discountMinor <= 0
      ? const SizedBox.shrink()
      : Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            context.l10n.promoDiscount(
              ride.promoCode ?? '',
              Money(ride.discountMinor, ride.currency).toDisplayString(),
            ),
            style: AppTextStyles.tabular(
              AppTextStyles.body,
            ).copyWith(color: context.colors.positive),
          ),
        );
}
