import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_countdown_bar.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart';

class DriverOfferOverlay extends StatelessWidget {
  const DriverOfferOverlay({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DriverOfferBloc, DriverOfferState>(
        listener: (context, state) {
          if (state.status == OfferStatus.accepted) {
            context.go('/driver/ride/${state.ride!.id}');
          }
        },
        builder: (context, state) => AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppSizes.contentDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: state.showing
              ? DriverOfferSheet(key: ValueKey(state.ride!.id), state: state)
              : const SizedBox.shrink(),
        ),
      );
}

class DriverOfferSheet extends StatelessWidget {
  const DriverOfferSheet({required this.state, super.key});
  final DriverOfferState state;
  @override
  Widget build(BuildContext context) {
    final ride = state.ride!;
    final l10n = context.l10n;
    final distance = ride.offerDistanceMeters ?? 0;
    final terminal =
        state.status == OfferStatus.expired || state.status == OfferStatus.lost;
    final secondary = context.textStyles.bodySmall?.copyWith(
      color: context.colors.textSecondary,
    );
    return ClipRRect(
      borderRadius: AppRadius.sheetBorder,
      child: ColoredBox(
        color: context.colors.sheet,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(context).height * AppSizes.offerSheetFraction,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MwCountdownBar(remaining: state.remaining, total: state.total),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(switch (ride.vehicleType) {
                              VehicleType.economy => l10n.vehicleEconomy,
                              VehicleType.comfort => l10n.vehicleComfort,
                              VehicleType.van => l10n.vehicleVan,
                            }, style: secondary),
                          ),
                          Text(
                            l10n.offerSeconds(
                              (state.remaining.inMilliseconds / 1000).ceil(),
                            ),
                            style: AppTextStyles.tabular(
                              AppTextStyles.footnote,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      // Price reads LTR but sits at the layout's start edge.
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.fareJod(
                            Money(ride.fareEstimatedFils).toJodString(),
                          ),
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.tabular(
                            AppTextStyles.largeTitle,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: AppSizes.timelineMark,
                            height: AppSizes.timelineMark,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.cash,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(l10n.cashPayment, style: secondary),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.offerPickupDistance(
                          math.max(1, (distance / 400).ceil()),
                          (distance / 1000).toStringAsFixed(1),
                        ),
                        style: context.textStyles.bodyMedium,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _Stop(stop: ride.pickup, pickup: true),
                      _Stop(stop: ride.dropoff, pickup: false),
                      Text(
                        l10n.offerTripDistance(
                          math.max(
                            1,
                            ((ride.route?.durationSeconds ?? 0) / 60).ceil(),
                          ),
                          ((ride.route?.distanceMeters ?? 0) / 1000)
                              .toStringAsFixed(1),
                        ),
                        style: secondary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      if (state.failure != null)
                        Text(
                          failureMessage(context, state.failure!),
                          style: secondary?.copyWith(
                            color: context.colors.negative,
                          ),
                        ),
                      if (terminal)
                        Text(
                          l10n.offerLost,
                          style: secondary,
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        MwPrimaryButton(
                          label: l10n.offerAccept,
                          height: AppSizes.offerButtonHeight,
                          isLoading: state.status == OfferStatus.accepting,
                          onPressed: state.busy
                              ? null
                              : () => context.read<DriverOfferBloc>().add(
                                  const AcceptPressed(),
                                ),
                        ),
                        TextButton(
                          onPressed: state.busy
                              ? null
                              : () => context.read<DriverOfferBloc>().add(
                                  const DeclinePressed(),
                                ),
                          child: Text(l10n.offerDecline),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.stop, required this.pickup});
  final RidePlace stop;
  final bool pickup;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: AppSpacing.md,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xs),
              Container(
                width: AppSizes.timelineMark,
                height: AppSizes.timelineMark,
                decoration: BoxDecoration(
                  shape: pickup ? BoxShape.circle : BoxShape.rectangle,
                  color: context.colors.textPrimary,
                ),
              ),
              if (pickup)
                Expanded(
                  child: Container(
                    width: AppSizes.timelineLine,
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: context.textStyles.titleMedium),
                Text(
                  stop.address,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
