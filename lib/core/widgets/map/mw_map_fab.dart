import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_shadows.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwMapFab extends StatelessWidget {
  const MwMapFab({
    required this.icon,
    required this.label,
    this.onPressed,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.mapFab,
    height: AppSizes.mapFab,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colors.sheet,
      boxShadow: AppShadows.soft,
    ),
    child: Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: AppSizes.icon,
          color: context.colors.textPrimary,
        ),
      ),
    ),
  );
}
