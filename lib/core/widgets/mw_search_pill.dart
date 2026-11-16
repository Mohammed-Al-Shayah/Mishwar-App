import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwSearchPill extends StatelessWidget {
  const MwSearchPill({this.onTap, super.key});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.fill,
    borderRadius: AppRadius.pillBorder,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: AppSizes.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Icon(AppIcons.search, size: AppSizes.searchIcon),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                context.l10n.whereTo,
                style: context.textStyles.titleMedium,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: context.colors.sheet,
                borderRadius: AppRadius.pillBorder,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.scheduleLater,
                    style: context.textStyles.labelMedium,
                  ),
                  Icon(AppIcons.caretDown, size: AppSizes.searchIcon),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
