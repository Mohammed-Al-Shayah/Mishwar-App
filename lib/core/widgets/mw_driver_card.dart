import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_party_info.dart';
import 'package:url_launcher/url_launcher.dart';

typedef RiderUriLauncher = Future<bool> Function(Uri uri);
Future<bool> launchRiderUri(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class MwDriverCard extends StatelessWidget {
  const MwDriverCard({
    required this.driver,
    this.launcher = launchRiderUri,
    super.key,
  });
  final RidePartyInfo driver;
  final RiderUriLauncher launcher;
  Future<void> _call() async {
    try {
      await launcher(Uri(scheme: 'tel', path: driver.phone));
    } on Object {
      /* The dialler may be unavailable. */
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = driver.vehicle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: AppSizes.driverAvatar / 2,
                  backgroundColor: context.colors.fill,
                  child: Text(
                    driver.name.isEmpty ? '' : driver.name.characters.first,
                    style: AppTextStyles.title2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: context.colors.fill,
                    borderRadius: AppRadius.pillBorder,
                  ),
                  child: Semantics(
                    label: context.l10n.riderRating(
                      driver.rating.toStringAsFixed(1),
                    ),
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.star, size: AppSizes.ratingStar),
                        Text(
                          context.l10n.tripRating(
                            driver.rating.toStringAsFixed(1),
                          ),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: AppTextStyles.headline),
                  if (vehicle != null)
                    Text(
                      context.l10n.riderVehicle(
                        vehicle.make,
                        vehicle.model,
                        vehicle.color,
                      ),
                      style: AppTextStyles.footnote.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  if (vehicle != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.fill,
                        borderRadius: AppRadius.buttonBorder,
                      ),
                      child: Text(
                        vehicle.plate,
                        textDirection: TextDirection.ltr,
                        style: AppTextStyles.title2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _action(
              context,
              AppIcons.phone,
              context.l10n.riderCall,
              () => unawaited(_call()),
            ),
            // TODO(T6.7): Enable sharing and safety tools.
            _action(context, AppIcons.share, context.l10n.riderShare, null),
            _action(context, AppIcons.shield, context.l10n.riderSafety, null),
          ],
        ),
      ],
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onPressed,
  ) => Flexible(
    child: Column(
      children: [
        SizedBox.square(
          dimension: AppSizes.tripActionCircle,
          child: IconButton.filledTonal(
            onPressed: onPressed,
            tooltip: label,
            style: IconButton.styleFrom(
              backgroundColor: context.colors.fill,
              disabledBackgroundColor: context.colors.fill,
              foregroundColor: context.colors.textPrimary,
              disabledForegroundColor: context.colors.textInactive,
            ),
            icon: Icon(icon, size: AppSizes.icon),
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    ),
  );
}
