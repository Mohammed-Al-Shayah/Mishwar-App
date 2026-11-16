import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwPaymentRow extends StatelessWidget {
  const MwPaymentRow({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: context.colors.cash,
            borderRadius: AppRadius.buttonBorder,
          ),
          child: Icon(AppIcons.cash, size: AppSizes.searchIcon),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(context.l10n.cashPayment, style: AppTextStyles.headline),
        ),
        Icon(AppIcons.chevron, size: AppSizes.icon),
      ],
    ),
  );
}
