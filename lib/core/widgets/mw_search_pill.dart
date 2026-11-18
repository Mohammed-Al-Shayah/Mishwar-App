import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwSearchPill extends StatelessWidget {
  const MwSearchPill({
    this.onTap,
    this.onSchedule,
    this.scheduleLabel,
    this.onClearSchedule,
    super.key,
  });
  final VoidCallback? onTap;
  final VoidCallback? onSchedule;
  final VoidCallback? onClearSchedule;
  final String? scheduleLabel;
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
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSizes.schedulePillWidth),
              child: InkWell(
                onTap: onSchedule,
                child: Container(
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
                      Flexible(
                        child: Text(
                          scheduleLabel ?? context.l10n.scheduleLater,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelMedium,
                        ),
                      ),
                      if (onClearSchedule != null)
                        IconButton(
                          onPressed: onClearSchedule,
                          tooltip: context.l10n.scheduleClear,
                          icon: Icon(AppIcons.close, size: AppSizes.searchIcon),
                        )
                      else
                        Icon(AppIcons.caretDown, size: AppSizes.searchIcon),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
