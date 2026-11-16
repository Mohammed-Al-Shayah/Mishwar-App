import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwPrimaryButton extends StatelessWidget {
  const MwPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? height;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height ?? AppSizes.buttonHeight,
    child: FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: isLoading
          ? FilledButton.styleFrom(
              disabledBackgroundColor: context.colors.primaryButton,
            )
          : null,
      child: isLoading
          ? SizedBox.square(
              dimension: AppSizes.icon,
              child: CircularProgressIndicator(
                color: context.colors.onPrimaryButton,
                strokeWidth: AppSizes.selectedBorder,
                semanticsLabel: label,
              ),
            )
          : Text(label),
    ),
  );
}
