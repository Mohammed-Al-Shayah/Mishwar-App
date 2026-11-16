import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwVehicleRow extends StatelessWidget {
  const MwVehicleRow({
    required this.name,
    required this.seats,
    required this.subtitle,
    required this.tagline,
    required this.price,
    required this.selected,
    required this.onTap,
    this.isVan = false,
    super.key,
  });
  final String name;
  final int seats;
  final String subtitle;
  final String tagline;
  final String price;
  final bool selected;
  final bool isVan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppSizes.vehicleSelectionDuration,
      constraints: BoxConstraints(minHeight: AppSizes.rowMinHeight),
      decoration: BoxDecoration(
        borderRadius: AppRadius.vehicleRowBorder,
        border: Border.all(
          width: AppSizes.selectedBorder,
          color: selected ? context.colors.textPrimary : context.colors.sheet,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.vehicleRowBorder,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                // TODO(design): replace with 3/4-view vehicle renders (DESIGN_SYSTEM §7)
                Container(
                  width: AppSizes.vehicleWidth,
                  height: AppSizes.vehicleHeight,
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: AppRadius.buttonBorder,
                  ),
                  child: Icon(
                    isVan ? AppIcons.van : AppIcons.car,
                    size: AppSizes.icon,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(name, style: AppTextStyles.headline),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.user, size: AppSizes.searchIcon),
                              Text('$seats', style: AppTextStyles.footnote),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.tabular(
                          AppTextStyles.footnote,
                        ).copyWith(color: context.colors.textSecondary),
                      ),
                      Text(
                        tagline,
                        style: AppTextStyles.footnote.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  price,
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.tabular(AppTextStyles.headline),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
