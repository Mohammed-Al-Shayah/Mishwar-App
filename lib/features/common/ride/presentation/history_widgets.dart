import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/time/amman_day.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

String historyDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.MMMEd(locale).add_jm().format(date.toLocal());
}

String ridePrice(BuildContext context, RideEntity ride) => context.l10n.fareJod(
  ((ride.status == RideStatus.cancelled
              ? ride.fareCancellationFeeFils
              : ride.fareFinalFils ?? ride.fareEstimatedFils) /
          1000)
      .toStringAsFixed(2),
);

class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      5,
      (_) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            MwSkeleton(width: AppSizes.iconCircle, height: AppSizes.iconCircle),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MwSkeleton(width: AppSizes.skeletonTitle),
                  SizedBox(height: AppSpacing.sm),
                  MwSkeleton(width: AppSizes.skeletonSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class HistoryRideRow extends StatelessWidget {
  const HistoryRideRow({
    required this.ride,
    required this.onTap,
    this.driver = false,
    this.trailing,
    super.key,
  });
  final RideEntity ride;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool driver;
  @override
  Widget build(BuildContext context) {
    final status = switch (ride.status) {
      RideStatus.cancelled => context.l10n.historyCancelled,
      RideStatus.noDrivers => context.l10n.historyNoDrivers,
      _ => null,
    };
    final locale = Localizations.localeOf(context).toString();
    final time = driver
        ? DateFormat.jm(
            locale,
          ).format(ammanTime(ride.completedAt ?? ride.createdAt))
        : historyDate(context, ride.scheduledFor ?? ride.createdAt);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: AppSizes.rowMinHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.iconCircle,
                    height: AppSizes.iconCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.fill,
                    ),
                    child: Icon(AppIcons.car, size: AppSizes.icon),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver
                              ? context.l10n.historyRoute(
                                  ride.pickup.name,
                                  ride.dropoff.name,
                                )
                              : ride.dropoff.name,
                          style: AppTextStyles.headline,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: time),
                              if (status != null)
                                TextSpan(
                                  text: context.l10n.historyStatusSuffix(
                                    status,
                                  ),
                                  style: TextStyle(
                                    color: ride.status == RideStatus.cancelled
                                        ? context.colors.negative
                                        : context.colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          style: AppTextStyles.tabular(
                            AppTextStyles.footnote,
                          ).copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (ride.status != RideStatus.noDrivers) ...[
                    SizedBox(width: AppSpacing.sm),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ridePrice(context, ride),
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.tabular(AppTextStyles.headline),
                        ),
                        ?trailing,
                      ],
                    ),
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
          child: Divider(height: AppSizes.divider, thickness: AppSizes.divider),
        ),
      ],
    );
  }
}
