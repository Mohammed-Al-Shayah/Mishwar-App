import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_shadows.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_markers.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({this.mapBuilder, super.key});
  final WidgetBuilder? mapBuilder;
  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _subtitleTimer;
  MwMapController? _map;
  BitmapDescriptor? _pickupIcon;
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
    if (!kIsWeb && widget.mapBuilder == null && _pickupIcon == null) {
      unawaited(_loadIcon());
    }
  }

  Future<void> _loadIcon() async {
    final icon = await MwMapMarkers.square(
      pickup: true,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    if (mounted) setState(() => _pickupIcon = icon);
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
  Future<void> _cancel() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.rideCancelTitle, style: AppTextStyles.title1),
              SizedBox(height: AppSpacing.xl),
              MwPrimaryButton(
                label: context.l10n.rideCancel,
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.rideKeepSearching),
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

  Widget _stop(BuildContext context, RidePlace place, {required bool pickup}) =>
      Row(
        children: [
          SizedBox(
            width: AppSizes.iconCircle,
            height: AppSizes.rowMinHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<RideTrackingBloc, RideTrackingState>(
    listener: (context, state) {
      _searching = state.ride?.status == RideStatus.searching;
      _motion();
      if (state.navigation == RideNavigation.home) context.go('/rider');
      if (state.navigation == RideNavigation.confirm) {
        context.go('/rider/confirm', extra: state.retryDraft);
      }
      final pickup = state.ride?.pickup.location;
      if (pickup != null) unawaited(_map?.animateTo(pickup));
    },
    builder: (context, state) {
      final ride = state.ride;
      final searching = ride?.status == RideStatus.searching;
      final noDrivers = ride?.status == RideStatus.noDrivers;
      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final sheetHeight =
                constraints.maxHeight * AppSizes.trackingSheetFraction;
            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => MwMap(
                    mapBuilder: widget.mapBuilder,
                    padding: EdgeInsets.only(bottom: sheetHeight),
                    markers: {
                      if (ride != null && _pickupIcon != null)
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: LatLng(
                            ride.pickup.location.lat,
                            ride.pickup.location.lng,
                          ),
                          icon: _pickupIcon!,
                          anchor: const Offset(0.5, 0.5),
                          infoWindow: InfoWindow(title: ride.pickup.name),
                        ),
                    },
                    circles: {
                      if (searching && ride != null)
                        for (var i = 0; i < 2; i++)
                          Circle(
                            circleId: CircleId('search-ring-$i'),
                            center: LatLng(
                              ride.pickup.location.lat,
                              ride.pickup.location.lng,
                            ),
                            radius:
                                AppSizes.searchRingRadiusMeters *
                                (_reduceMotion
                                    ? (i + 1) / 2
                                    : ((_pulse.value + i / 2) % 1)),
                            strokeColor: context.colors.textPrimary.withValues(
                              alpha: _reduceMotion
                                  ? 0.3
                                  : 1 - ((_pulse.value + i / 2) % 1),
                            ),
                            strokeWidth: AppSizes.routeWidth,
                          ),
                    },
                    onMapCreated: (controller) {
                      _map = controller;
                      final pickup = context
                          .read<RideTrackingBloc>()
                          .state
                          .ride
                          ?.pickup
                          .location;
                      if (pickup != null) {
                        unawaited(controller.animateTo(pickup));
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
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
                                    : context.l10n.rideAccepted,
                                style: AppTextStyles.title1,
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
                              _stop(context, ride.pickup, pickup: true),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: AppSizes.iconCircle / 2,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Container(
                                    width: AppSizes.timelineLine,
                                    height: AppSpacing.sm,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ),
                              _stop(context, ride.dropoff, pickup: false),
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
                                      : _cancel,
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
                                          context.l10n.rideCancel,
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
