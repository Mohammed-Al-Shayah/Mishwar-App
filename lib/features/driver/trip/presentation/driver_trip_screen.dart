import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/geo/polyline.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/map/mw_map_markers.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/presentation/fee_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/parcel_widgets.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_tools.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart'
    as presence;
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart';
import 'package:mishwar/features/driver/trip/presentation/parcel_delivery_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

typedef TripLauncher = Future<bool> Function(Uri uri);
Future<bool> launchTripUri(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class DriverTripScreen extends StatelessWidget {
  const DriverTripScreen({
    this.mapBuilder,
    this.launcher = launchTripUri,
    super.key,
  });
  final WidgetBuilder? mapBuilder;
  final TripLauncher launcher;
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark(),
    child: _TripView(mapBuilder: mapBuilder, launcher: launcher),
  );
}

class _TripView extends StatefulWidget {
  const _TripView({required this.mapBuilder, required this.launcher});
  final WidgetBuilder? mapBuilder;
  final TripLauncher launcher;
  @override
  State<_TripView> createState() => _TripViewState();
}

class _TripViewState extends State<_TripView> {
  MwMapController? _map;
  BitmapDescriptor? _pickup;
  BitmapDescriptor? _dropoff;
  @override
  void initState() {
    super.initState();
    context.read<DriverTripBloc>().add(const Started());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && widget.mapBuilder == null && _pickup == null) {
      unawaited(_icons());
    }
  }

  Future<void> _icons() async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final pickup = await MwMapMarkers.square(pickup: true, pixelRatio: ratio);
    final dropoff = await MwMapMarkers.square(pickup: false, pixelRatio: ratio);
    if (mounted) {
      setState(() {
        _pickup = pickup;
        _dropoff = dropoff;
      });
    }
  }

  void _send(DriverTripEvent event) {
    unawaited(HapticFeedback.lightImpact());
    context.read<DriverTripBloc>().add(event);
  }

  RidePlace _target(DriverTripState state) => state.phase == TripPhase.onTrip
      ? state.ride!.dropoff
      : state.ride!.pickup;
  void _fit() {
    final state = context.read<DriverTripBloc>().state;
    if (state.ride == null) return;
    final fix = context.read<presence.DriverPresenceBloc>().state.lastFix;
    unawaited(
      _map?.fitBounds([
        if (fix != null) fix.point,
        _target(state).location,
      ], AppSpacing.xl),
    );
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await widget.launcher(uri);
    } on Object {
      return false;
    }
  }

  Future<void> _navigate(RidePlace target) async {
    final coordinates = '${target.location.lat},${target.location.lng}';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (await _launch(Uri.parse('google.navigation:q=$coordinates&mode=d'))) {
        return;
      }
    }
    final opened = await _launch(
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$coordinates&travelmode=driving',
      ),
    );
    if (!opened && mounted) _launchFailure();
  }

  void _launchFailure() => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
  Future<void> _call(String phone) async {
    if (!await _launch(Uri(scheme: 'tel', path: phone)) && mounted) {
      _launchFailure();
    }
  }

  Future<void> _confirm({required bool cancel}) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cancel
                      ? context.l10n.tripCancelConfirm
                      : context.l10n.tripCompleteConfirm,
                  style: AppTextStyles.title1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),
                MwPrimaryButton(
                  label: cancel
                      ? context.l10n.tripCancel
                      : context.l10n.tripComplete,
                  height: AppSizes.offerButtonHeight,
                  onPressed: () => Navigator.pop(context, true),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.tripNo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted && confirmed == true) {
      _send(cancel ? const CancelPressed() : const CompletePressed());
    }
  }

  Future<void> _overflow() async {
    final phase = context.read<DriverTripBloc>().state.phase;
    final cancel = await showModalBottomSheet<bool>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(AppIcons.shield),
                title: Text(context.l10n.safetyTitle),
                onTap: () => Navigator.pop(context, false),
              ),
              if (phase != TripPhase.onTrip)
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    context.l10n.tripCancel,
                    style: AppTextStyles.headline.copyWith(
                      color: context.colors.negative,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted && cancel == false) {
      await showTripSafety(context, launcher: widget.launcher, driver: true);
    }
    if (mounted && cancel == true) await _confirm(cancel: true);
  }

  Widget _circle({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool small = false,
  }) => SizedBox.square(
    dimension: small ? AppSizes.iconCircle : AppSizes.tripActionCircle,
    child: IconButton.filledTonal(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: context.colors.fill),
      icon: Icon(icon, size: AppSizes.icon),
    ),
  );
  Widget _top(DriverTripState state) {
    final target = _target(state);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheet,
        borderRadius: AppRadius.tileBorder,
      ),
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (state.phase) {
                    TripPhase.waiting => context.l10n.tripWaiting,
                    TripPhase.onTrip => context.l10n.tripOnTrip,
                    _ => context.l10n.tripToPickup,
                  },
                  style: AppTextStyles.footnote.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  target.name,
                  style: AppTextStyles.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  target.address,
                  style: AppTextStyles.footnote.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          _circle(
            label: context.l10n.tripNavigate,
            icon: AppIcons.map,
            onPressed: () => unawaited(_navigate(target)),
          ),
        ],
      ),
    );
  }

  Widget _sheet(DriverTripState state) {
    final ride = state.ride!;
    final rider = ride.riderInfo;
    final cash = state.phase == TripPhase.collectCash;
    final elapsed = state.waitingElapsed;
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final time = '${elapsed.inMinutes}:$seconds';
    return Container(
      decoration: BoxDecoration(
        color: context.colors.sheet,
        borderRadius: AppRadius.sheetBorder,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cash) ...[
                  Text(
                    context.l10n.tripCashPrompt,
                    style: AppTextStyles.footnote,
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Price reads LTR but sits at the layout's start edge.
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      ride.fareFinalFils == null
                          ? context.l10n.errorGeneric
                          : context.l10n.tripPrice(
                              Money(ride.fareFinalFils!).toJodString(),
                            ),
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.tabular(AppTextStyles.largeTitle),
                    ),
                  ),
                  FareFeeRows(ride: ride),
                  if (ride.promoApplied == true && ride.discountFils > 0)
                    Text(
                      context.l10n.promoCashFootnote(
                        Money(ride.discountFils).toJodString(),
                      ),
                      style: AppTextStyles.footnote,
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Chip(
                      avatar: Icon(
                        AppIcons.cash,
                        color: context.colors.cash,
                        size: AppSizes.icon,
                      ),
                      label: Text(
                        context.l10n.cashPayment,
                        style: AppTextStyles.footnote.copyWith(
                          color: context.colors.cash,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.tripActionCircle / 2,
                        backgroundColor: context.colors.fill,
                        foregroundColor: context.colors.textPrimary,
                        child: Text(
                          rider == null || rider.name.isEmpty
                              ? ''
                              : rider.name.characters.first,
                          style: AppTextStyles.headline,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rider?.name ?? '',
                              style: AppTextStyles.headline,
                            ),
                            if (rider != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppIcons.star,
                                    size: AppTextStyles.footnote.fontSize,
                                  ),
                                  SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    context.l10n.tripRating(
                                      rider.rating.toStringAsFixed(1),
                                    ),
                                    style: AppTextStyles.tabular(
                                      AppTextStyles.footnote,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      _circle(
                        label: context.l10n.tripCall,
                        icon: AppIcons.phone,
                        onPressed: rider == null || rider.phone.isEmpty
                            ? null
                            : () => unawaited(_call(rider.phone)),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  if (state.phase == TripPhase.waiting)
                    Text(
                      elapsed.inMilliseconds > WaitingDisplay.freeSeconds * 1000
                          ? context.l10n.waitingFeeRunning(
                              feeAmount(
                                context,
                                WaitingDisplay.feeFils(elapsed),
                              ),
                            )
                          : context.l10n.tripWaitingTime(time),
                      style: AppTextStyles.tabular(AppTextStyles.largeTitle),
                    ),
                  if (state.phase == TripPhase.onTrip) ...[
                    Text(ride.dropoff.name, style: AppTextStyles.headline),
                    if (ride.route != null)
                      Text(
                        context.l10n.offerTripDistance(
                          (ride.route!.durationSeconds / 60).ceil(),
                          (ride.route!.distanceMeters / 1000).toStringAsFixed(
                            1,
                          ),
                        ),
                        style: AppTextStyles.footnote,
                      ),
                  ],
                ],
                if (ride.parcel case final parcel?) ...[
                  Text(parcel.description, style: AppTextStyles.body),
                  if (state.phase == TripPhase.onTrip)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        parcel.recipientName,
                        style: AppTextStyles.headline,
                      ),
                      subtitle: Text(
                        context.l10n.parcelRecipient,
                        style: AppTextStyles.footnote,
                      ),
                      trailing: _circle(
                        label: context.l10n.tripCall,
                        icon: AppIcons.phone,
                        onPressed: () =>
                            unawaited(_call(parcel.recipientPhone)),
                      ),
                    ),
                  if (parcel.photoPath != null)
                    ParcelPhotoButton(
                      rideId: ride.id,
                      launcher: widget.launcher,
                    ),
                ],
                if (state.failure != null)
                  Text(
                    state.failure ==
                            const RideActionFailure(
                              RideActionFailureReason.tooFar,
                            )
                        ? context.l10n.tripTooFar
                        : failureMessage(context, state.failure!),
                    style: AppTextStyles.footnote.copyWith(
                      color: context.colors.negative,
                    ),
                  ),
                SizedBox(height: AppSpacing.md),
                MwPrimaryButton(
                  height: AppSizes.offerButtonHeight,
                  isLoading: state.busy,
                  label: switch (state.phase) {
                    TripPhase.toPickup
                        when ride.status == RideStatus.accepted =>
                      context.l10n.rideTryAgain,
                    TripPhase.waiting => context.l10n.tripStart,
                    TripPhase.onTrip =>
                      ride.parcel != null
                          ? context.l10n.parcelDeliver
                          : context.l10n.tripComplete,
                    TripPhase.collectCash => context.l10n.tripCashCollected,
                    _ => context.l10n.tripArrived,
                  },
                  onPressed:
                      state.terminal || (cash && ride.fareFinalFils == null)
                      ? null
                      : () {
                          switch (state.phase) {
                            case TripPhase.toPickup:
                              _send(
                                ride.status == RideStatus.accepted
                                    ? const RetryPressed()
                                    : const ArrivedPressed(),
                              );
                            case TripPhase.waiting:
                              _send(const StartPressed());
                            case TripPhase.onTrip:
                              unawaited(
                                ride.parcel != null
                                    ? showParcelDeliverySheet(context)
                                    : _confirm(cancel: false),
                              );
                            case TripPhase.collectCash:
                              _send(const CashCollectedPressed());
                            case TripPhase.done ||
                                TripPhase.cancelled ||
                                TripPhase.redispatched:
                              break;
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Set<Polyline> _route(DriverTripState state) {
    final encoded = state.ride?.route?.polyline;
    if (state.phase != TripPhase.onTrip || encoded == null) return {};
    try {
      return {
        Polyline(
          polylineId: const PolylineId('trip'),
          color: context.colors.route,
          width: AppSizes.routeWidth,
          points: decodePolyline(
            encoded,
          ).map((p) => LatLng(p.lat, p.lng)).toList(),
        ),
      };
    } on FormatException {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: BlocConsumer<DriverTripBloc, DriverTripState>(
      listener: (context, state) {
        if (state.terminal) {
          if (state.phase != TripPhase.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.phase == TripPhase.redispatched
                      ? context.l10n.tripRedispatched
                      : context.l10n.tripCancelled,
                ),
              ),
            );
          }
          context.go(
            state.phase == TripPhase.done
                ? '/driver/ride/${state.ride!.id}/rate'
                : '/driver',
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fit();
          });
        }
      },
      builder: (context, state) =>
          BlocListener<
            presence.DriverPresenceBloc,
            presence.DriverPresenceState
          >(
            listenWhen: (a, b) => a.lastFix != b.lastFix,
            listener: (_, _) => _fit(),
            child: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final sheetHeight =
                      constraints.maxHeight * AppSizes.tripSheetFraction;
                  final topHeight =
                      constraints.maxHeight * AppSizes.tripTopFraction;
                  final fix = context
                      .watch<presence.DriverPresenceBloc>()
                      .state
                      .lastFix;
                  final target = state.ride == null ? null : _target(state);
                  final pickup = state.phase != TripPhase.onTrip;
                  final icon = pickup ? _pickup : _dropoff;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      MwMap(
                        mapBuilder: widget.mapBuilder,
                        permissionGranted: fix != null,
                        padding: EdgeInsets.only(
                          bottom: sheetHeight,
                          top: topHeight,
                        ),
                        polylines: _route(state),
                        markers: {
                          if (target != null && icon != null)
                            Marker(
                              markerId: MarkerId(pickup ? 'pickup' : 'dropoff'),
                              position: LatLng(
                                target.location.lat,
                                target.location.lng,
                              ),
                              icon: icon,
                              infoWindow: InfoWindow(
                                title: target.name,
                                snippet: target.address,
                              ),
                              anchor: const Offset(0.5, 0.5),
                            ),
                        },
                        onMapCreated: (map) {
                          _map = map;
                          _fit();
                        },
                      ),
                      if (state.ride != null && !state.terminal) ...[
                        if (state.phase != TripPhase.collectCash)
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: topHeight,
                                      ),
                                      child: SingleChildScrollView(
                                        child: _top(state),
                                      ),
                                    ),
                                    if (state.phase == TripPhase.toPickup ||
                                        state.phase == TripPhase.waiting ||
                                        state.phase == TripPhase.onTrip)
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        child: _circle(
                                          label: context.l10n.tripMore,
                                          icon: AppIcons.more,
                                          small: true,
                                          onPressed: state.busy
                                              ? null
                                              : () => unawaited(_overflow()),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: MwMapFab(
                                    icon: AppIcons.recenter,
                                    label: context.l10n.recenterMap,
                                    onPressed: _fit,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: sheetHeight,
                                child: _sheet(state),
                              ),
                            ],
                          ),
                        ),
                      ] else if (state.failure != null)
                        Center(
                          child: Text(failureMessage(context, state.failure!)),
                        )
                      else
                        const Center(child: CircularProgressIndicator()),
                    ],
                  );
                },
              ),
            ),
          ),
    ),
  );
}
