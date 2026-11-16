import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwListRow extends StatelessWidget {
  const MwListRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSizes.rowMinHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Container(
                  width: AppSizes.iconCircle,
                  height: AppSizes.iconCircle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.fill,
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.icon,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textStyles.titleMedium),
                      Text(
                        subtitle,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppSpacing.xs),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSizes.iconCircle + AppSpacing.sm,
        ),
        child: Divider(
          height: AppSizes.divider,
          thickness: AppSizes.divider,
          color: context.colors.divider,
        ),
      ),
    ],
  );
}
