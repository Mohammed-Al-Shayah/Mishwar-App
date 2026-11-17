import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_shadows.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_driver_card.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/trip_stops.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';
import 'package:mishwar/features/rider/ride/presentation/rider_trip_map.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({
    this.mapBuilder,
    this.launcher = launchRiderUri,
    super.key,
  });
  final RiderUriLauncher launcher;
  final WidgetBuilder? mapBuilder;
  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _subtitleTimer;
  bool _assigned = false;
  bool _reduceMotion = false;
  bool _searching = false;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: AppSizes.searchPulseDuration,
    );
    context.read<RideTrackingBloc>().add(const RideTrackingStarted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _motion();
  }

  void _motion() {
    if (_searching && !_reduceMotion) {
      if (!_pulse.isAnimating) unawaited(_pulse.repeat());
      _subtitleTimer ??= Timer.periodic(AppSizes.searchSubtitleDuration, (_) {
        context.read<RideTrackingBloc>().add(const RideSubtitleTicked());
      });
    } else {
      _pulse.stop();
      _subtitleTimer?.cancel();
      _subtitleTimer = null;
    }
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  String _vehicle(BuildContext context, VehicleType type) => switch (type) {
    VehicleType.economy => context.l10n.vehicleEconomy,
    VehicleType.comfort => context.l10n.vehicleComfort,
    VehicleType.van => context.l10n.vehicleVan,
  };
  Future<void> _cancel(BuildContext sheetContext) async {
    final searching =
        context.read<RideTrackingBloc>().state.ride?.status ==
        RideStatus.searching;
    final confirmed = await showModalBottomSheet<bool>(
      context: sheetContext,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                searching
                    ? context.l10n.rideCancelTitle
                    : context.l10n.riderCancelConfirm,
                style: AppTextStyles.title1,
              ),
              SizedBox(height: AppSpacing.xl),
              MwPrimaryButton(
                label: searching
                    ? context.l10n.rideCancel
                    : context.l10n.riderCancel,
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  searching
                      ? context.l10n.rideKeepSearching
                      : context.l10n.riderContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && confirmed == true) {
      context.read<RideTrackingBloc>().add(const RideCancelRequested());
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => Theme(
    data: AppTheme.light(),
    child: Builder(builder: _buildTrip),
  );
  Widget _buildTrip(
    BuildContext context,
  ) => BlocConsumer<RideTrackingBloc, RideTrackingState>(
    listener: (context, state) {
      _searching = state.ride?.status == RideStatus.searching;
      _motion();
      if (state.navigation == RideNavigation.home) context.go('/rider');
      if (state.navigation == RideNavigation.confirm) {
        context.go('/rider/confirm', extra: state.retryDraft);
      }
      if (state.navigation == RideNavigation.summary) {
        context.go('/rider/ride/${state.ride!.id}/summary');
      }
      final assigned =
          state.ride?.driverId != null &&
          state.ride?.status != RideStatus.searching;
      if (assigned && !_assigned) unawaited(HapticFeedback.mediumImpact());
      _assigned = assigned;
    },
    builder: (context, state) {
      final ride = state.ride;
      final searching = ride?.status == RideStatus.searching;
      final noDrivers = ride?.status == RideStatus.noDrivers;
      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final sheetHeight =
                constraints.maxHeight *
                (searching || noDrivers
                    ? AppSizes.trackingSheetFraction
                    : AppSizes.riderTripSheetFraction);
            return Stack(
              fit: StackFit.expand,
              children: [
                RiderTripMap(
                  state: state,
                  sheetHeight: sheetHeight,
                  pulse: _pulse,
                  mapBuilder: widget.mapBuilder,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: _reduceMotion
                        ? Duration.zero
                        : AppSizes.contentDuration,
                    curve: Curves.easeOutCubic,
                    height: sheetHeight,
                    decoration: BoxDecoration(
                      color: context.colors.sheet,
                      borderRadius: AppRadius.sheetBorder,
                      boxShadow: AppShadows.soft,
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: AppSizes.grabberWidth,
                                height: AppSizes.grabberHeight,
                                decoration: BoxDecoration(
                                  color: context.colors.grabber,
                                  borderRadius: AppRadius.pillBorder,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            if (ride == null) ...[
                              if (state.failure == null)
                                const LinearProgressIndicator(),
                              if (state.failure != null) ...[
                                Text(failureMessage(context, state.failure!)),
                                MwPrimaryButton(
                                  label: context.l10n.confirmRetry,
                                  onPressed: () => context
                                      .read<RideTrackingBloc>()
                                      .add(const RideTrackingStarted()),
                                ),
                              ],
                            ] else ...[
                              Text(
                                noDrivers
                                    ? context.l10n.rideNoDrivers
                                    : searching
                                    ? context.l10n.searchingTitle
                                    : switch (ride.status) {
                                        RideStatus.arrived =>
                                          context.l10n.riderArrived,
                                        RideStatus.inProgress =>
                                          context.l10n.riderArrival(
                                            DateFormat.jm(
                                              Localizations.localeOf(
                                                context,
                                              ).toLanguageTag(),
                                            ).format(
                                              (state.now ?? DateTime.now()).add(
                                                Duration(
                                                  minutes: state.etaMinutes,
                                                ),
                                              ),
                                            ),
                                          ),
                                        _ => context.l10n.riderEta(
                                          state.etaMinutes,
                                        ),
                                      },
                                style: AppTextStyles.title1,
                              ),
                              if (state.redispatchNotice)
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  color: context.colors.fill,
                                  child: Text(
                                    context.l10n.riderRedispatched,
                                    style: AppTextStyles.footnote,
                                  ),
                                ),
                              if (ride.status == RideStatus.arrived &&
                                  state.waitingSince != null)
                                Text(
                                  context.l10n.riderWaiting(
                                    ((state.now ?? DateTime.now())
                                                .difference(state.waitingSince!)
                                                .inSeconds /
                                            60)
                                        .floor()
                                        .clamp(0, 9999),
                                  ),
                                  style: AppTextStyles.footnote,
                                ),
                              if (ride.status == RideStatus.inProgress)
                                Text(
                                  ride.dropoff.name,
                                  style: AppTextStyles.footnote,
                                ),
                              if (!searching && ride.driverInfo != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  child: MwDriverCard(
                                    driver: ride.driverInfo!,
                                    launcher: widget.launcher,
                                  ),
                                ),
                              if (searching) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  switch (state.subtitleIndex) {
                                    1 => context.l10n.searchingVehicle(
                                      _vehicle(context, ride.vehicleType),
                                    ),
                                    2 => context.l10n.searchingNearby,
                                    _ => context.l10n.searchingQuick,
                                  },
                                  style: AppTextStyles.footnote.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.md),
                                LinearProgressIndicator(
                                  minHeight: AppSizes.searchProgressHeight,
                                  value: _reduceMotion ? 0.5 : null,
                                  color: context.colors.textPrimary,
                                  backgroundColor: context.colors.fill,
                                ),
                              ],
                              SizedBox(height: AppSpacing.sm),
                              TripStops(ride: ride),
                              Divider(
                                height: AppSpacing.md,
                                thickness: AppSizes.divider,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _vehicle(context, ride.vehicleType),
                                      style: AppTextStyles.headline,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.fareJod(
                                      Money(
                                        ride.fareEstimatedFils,
                                      ).toJodString(),
                                    ),
                                    style: AppTextStyles.tabular(
                                      AppTextStyles.headline,
                                    ),
                                  ),
                                ],
                              ),
                              // Colour carries meaning only: a cash dot,
                              // readable text in the normal text colour.
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
                                  Text(
                                    context.l10n.riderCash,
                                    style: AppTextStyles.footnote.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (state.failure != null)
                                Text(
                                  failureMessage(context, state.failure!),
                                  style: AppTextStyles.footnote.copyWith(
                                    color: context.colors.negative,
                                  ),
                                ),
                              SizedBox(height: AppSpacing.md),
                              if (noDrivers) ...[
                                MwPrimaryButton(
                                  label: context.l10n.rideTryAgain,
                                  onPressed: () => context
                                      .read<RideTrackingBloc>()
                                      .add(const RideRetryRequested()),
                                ),
                                TextButton(
                                  onPressed: () => context
                                      .read<RideTrackingBloc>()
                                      .add(const RideBackRequested()),
                                  child: Text(context.l10n.rideBack),
                                ),
                              ] else if ([
                                RideStatus.searching,
                                RideStatus.accepted,
                                RideStatus.arriving,
                                RideStatus.arrived,
                              ].contains(ride.status))
                                TextButton(
                                  onPressed: state.isCancelling
                                      ? null
                                      : () => _cancel(context),
                                  child: state.isCancelling
                                      ? SizedBox.square(
                                          dimension: AppSizes.icon,
                                          child: CircularProgressIndicator(
                                            color: context.colors.textPrimary,
                                            strokeWidth:
                                                AppSizes.selectedBorder,
                                          ),
                                        )
                                      : Text(
                                          searching
                                              ? context.l10n.rideCancel
                                              : context.l10n.riderCancel,
                                          style: AppTextStyles.headline
                                              .copyWith(
                                                color: context.colors.negative,
                                              ),
                                        ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
