import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';

/// Static loading placeholder that also respects reduced motion.
class MwSkeleton extends StatelessWidget {
  const MwSkeleton({this.width, this.height, super.key});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height ?? AppSizes.skeletonBar,
    decoration: BoxDecoration(
      color: context.colors.fill,
      borderRadius: AppRadius.buttonBorder,
    ),
  );
}
