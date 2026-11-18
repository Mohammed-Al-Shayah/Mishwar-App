import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';

/// Monochrome address tag for a map pin.
class MwPinLabel extends StatelessWidget {
  const MwPinLabel({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(maxWidth: AppSizes.skeletonSubtitle),
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: context.colors.textPrimary,
      borderRadius: BorderRadius.circular(AppRadius.pinLabel),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.footnote.copyWith(
              color: context.colors.surface,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Icon(
          AppIcons.chevron,
          size: AppSizes.pinSize,
          color: context.colors.surface,
        ),
      ],
    ),
  );
}
