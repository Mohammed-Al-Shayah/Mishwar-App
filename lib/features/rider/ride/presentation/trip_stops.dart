import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

class TripStops extends StatelessWidget {
  const TripStops({required this.ride, super.key});
  final RideEntity ride;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _stop(context, ride.pickup, pickup: true),
      _stop(context, ride.dropoff, pickup: false),
    ],
  );
  Widget _stop(BuildContext context, RidePlace place, {required bool pickup}) =>
      Row(
        children: [
          SizedBox(
            width: AppSizes.iconCircle,
            height: AppSizes.rowMinHeight,
            // The connector runs from below the pickup mark to above the
            // drop-off mark, so the two rows read as one continuous route.
            child: Column(
              children: [
                Expanded(child: pickup ? const SizedBox() : _line(context)),
                Container(
                  width: AppSizes.timelineMark,
                  height: AppSizes.timelineMark,
                  decoration: BoxDecoration(color: context.colors.textPrimary),
                  child: pickup
                      ? Center(
                          child: Container(
                            width: AppSizes.pinInner,
                            height: AppSizes.pinInner,
                            color: context.colors.sheet,
                          ),
                        )
                      : null,
                ),
                Expanded(child: pickup ? _line(context) : const SizedBox()),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: AppTextStyles.headline),
                Text(
                  place.address,
                  style: AppTextStyles.footnote.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  Widget _line(BuildContext context) => Container(
    width: AppSizes.timelineLine,
    color: context.colors.textPrimary,
  );
}
