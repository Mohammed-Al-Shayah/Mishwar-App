import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mishwar/core/geo/polyline.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_shadows.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/map/mw_map_markers.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_payment_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/core/widgets/mw_vehicle_row.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';
import 'package:mishwar/features/rider/confirm/presentation/promo_sheet.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/schedule_sheet.dart';

class RideConfirmScreen extends StatefulWidget {
  const RideConfirmScreen({
    required this.draft,
    this.mapBuilder,
    this.pickupAvailable,
    super.key,
  });
  final RideDraft draft;
  final bool? pickupAvailable;
  final WidgetBuilder? mapBuilder;
  @override
  State<RideConfirmScreen> createState() => _RideConfirmScreenState();
}

class _RideConfirmScreenState extends State<RideConfirmScreen> {
  RideDraft get _draft => context.read<RideConfirmCubit>().draft;
  MwMapController? _controller;
  Future<void> _editPickup() async {
    final cubit = context.read<RideConfirmCubit>();
    final stop = await context.push<RideStop>(
      '/rider/pickup',
      extra: cubit.draft.pickup,
    );
    if (!mounted || stop == null) return;
    await cubit.updatePickup(stop);
    if (mounted && !kIsWeb && widget.mapBuilder == null) await _loadMarkers();
  }

  Set<Marker> _markers = {};
  late final DateTime _now;
  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    unawaited(context.read<RideConfirmCubit>().start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && widget.mapBuilder == null) unawaited(_loadMarkers());
  }

  Future<void> _loadMarkers() async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final icons = await Future.wait([
      MwMapMarkers.square(pickup: true, pixelRatio: ratio),
      MwMapMarkers.square(pickup: false, pixelRatio: ratio),
    ]);
    if (!mounted) return;
    setState(
      () => _markers = {
        for (var i = 0; i < 2; i++)
          Marker(
            markerId: MarkerId(i == 0 ? 'pickup' : 'dropoff'),
            position: LatLng(
              (i == 0 ? _draft.pickup : _draft.dropoff).location.lat,
              (i == 0 ? _draft.pickup : _draft.dropoff).location.lng,
            ),
            icon: icons[i],
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: (i == 0 ? _draft.pickup : _draft.dropoff).name,
            ),
          ),
      },
    );
  }

  List<GeoPointValue> _route(RideConfirmState state) =>
      state is RideConfirmLoaded ? decodePolyline(state.route.polyline) : [];

  void _fit(RideConfirmState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _controller?.fitBounds([
          _draft.pickup.location,
          _draft.dropoff.location,
          ..._route(state),
        ], AppSpacing.xl),
      );
    });
  }

  String _name(BuildContext context, VehicleType type) => switch (type) {
    VehicleType.economy => context.l10n.vehicleEconomy,
    VehicleType.comfort => context.l10n.vehicleComfort,
    VehicleType.van => context.l10n.vehicleVan,
  };

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<RideConfirmCubit, RideConfirmState>(
    listener: (_, state) {
      if (state is RideConfirmLoaded && state is! RideConfirmRequested) {
        _fit(state);
      }
      if (state is RideConfirmRequested) {
        if (_draft.scheduledFor != null) {
          context.go('/rider/history');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.scheduleSuccess)));
        } else {
          context.go('/rider/ride/${state.rideId}');
        }
      }
    },
    builder: (context, state) => Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sheetHeight =
              constraints.maxHeight * AppSizes.confirmSheetFraction;
          final loaded = state is RideConfirmLoaded ? state : null;
          final minutes = loaded == null
              ? 0
              : (loaded.route.durationSeconds / 60).ceil();
          final arrival = loaded == null
              ? ''
              : DateFormat.jm(
                  Localizations.localeOf(context).toString(),
                ).format(
                  (_draft.scheduledFor ?? _now).add(
                    Duration(
                      milliseconds: (loaded.route.durationSeconds * 1000)
                          .round(),
                    ),
                  ),
                );
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: MwMap(
                  mapBuilder: widget.mapBuilder,
                  padding: EdgeInsets.only(bottom: sheetHeight),
                  markers: _markers,
                  polylines: {
                    if (loaded != null)
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: context.colors.route,
                        width: AppSizes.routeWidth,
                        points: _route(
                          state,
                        ).map((p) => LatLng(p.lat, p.lng)).toList(),
                      ),
                  },
                  onMapCreated: (controller) {
                    _controller = controller;
                    _fit(state);
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MwMapFab(
                        icon: AppIcons.back,
                        label: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: () => context.pop(),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      if (loaded != null)
                        Expanded(
                          child: Center(
                            heightFactor: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pinLabel,
                                ),
                              ),
                              child: Text(
                                context.l10n.tripPill(
                                  minutes,
                                  _draft.dropoff.name,
                                ),
                                style: AppTextStyles.tabular(
                                  AppTextStyles.footnote,
                                ).copyWith(color: AppColors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(width: AppSizes.mapFab + AppSpacing.xs),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: sheetHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.sheet,
                    borderRadius: AppRadius.sheetBorder,
                    boxShadow: AppShadows.soft,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Column(
                        children: [
                          SizedBox(height: AppSpacing.xs),
                          Container(
                            width: AppSizes.grabberWidth,
                            height: AppSizes.grabberHeight,
                            decoration: BoxDecoration(
                              color: context.colors.grabber,
                              borderRadius: AppRadius.pillBorder,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              _draft.parcel != null
                                  ? context.l10n.parcelTitle
                                  : context.l10n.chooseRide,
                              style: AppTextStyles.headline,
                            ),
                          ),
                          Divider(
                            height: AppSizes.divider,
                            thickness: AppSizes.divider,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  MwListRow(
                                    icon: AppIcons.mapPin,
                                    title: context.l10n.pickupEdit,
                                    subtitle: _draft.pickup.name,
                                    onTap:
                                        kIsWeb ||
                                            !(widget.pickupAvailable ??
                                                widget.mapBuilder == null) ||
                                            state is RideConfirmLoading ||
                                            (loaded?.isRequesting ?? false)
                                        ? null
                                        : _editPickup,
                                  ),
                                  if (loaded != null)
                                    for (final type
                                        in (_draft.parcel == null
                                            ? VehicleType.values
                                            : [VehicleType.economy]))
                                      MwVehicleRow(
                                        key: ValueKey(type),
                                        name: _name(context, type),
                                        priceLabel: loaded.airport == null
                                            ? null
                                            : context.l10n.airportFixedFare,
                                        seats: type == VehicleType.van ? 6 : 4,
                                        isVan: type == VehicleType.van,
                                        selected: loaded.selected == type,
                                        onTap: () => context
                                            .read<RideConfirmCubit>()
                                            .select(type),
                                        subtitle: context.l10n.arrivalDuration(
                                          arrival,
                                          minutes,
                                        ),
                                        tagline: switch (type) {
                                          VehicleType.economy =>
                                            context.l10n.economyTagline,
                                          VehicleType.comfort =>
                                            context.l10n.comfortTagline,
                                          VehicleType.van =>
                                            context.l10n.vanTagline,
                                        },
                                        originalPrice:
                                            loaded.selected == type &&
                                                loaded.promoQuote != null
                                            ? context.l10n.fareAmount(
                                                Money(
                                                  loaded
                                                      .promoQuote!
                                                      .fareBeforeMinor,
                                                  loaded.fares.first.currency,
                                                ).toDisplayString(),
                                              )
                                            : null,
                                        price:
                                            loaded.selected == type &&
                                                loaded.promoQuote != null
                                            ? context.l10n.fareAmount(
                                                Money(
                                                  loaded
                                                      .promoQuote!
                                                      .fareAfterMinor,
                                                  loaded.fares.first.currency,
                                                ).toDisplayString(),
                                              )
                                            : context.l10n.fareAmount(
                                                Money(
                                                  loaded.fares
                                                      .firstWhere(
                                                        (f) =>
                                                            f.vehicleType ==
                                                            type,
                                                      )
                                                      .minor,
                                                  loaded.fares.first.currency,
                                                ).toDisplayString(),
                                              ),
                                      ),
                                  if (state is RideConfirmLoading)
                                    for (var i = 0; i < 3; i++)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: MwSkeleton(
                                          height: AppSizes.rowMinHeight,
                                        ),
                                      ),
                                  if (state is RideConfirmFailure)
                                    Padding(
                                      padding: EdgeInsets.all(AppSpacing.md),
                                      child: Column(
                                        children: [
                                          Text(
                                            failureMessage(
                                              context,
                                              state.failure,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context
                                                .read<RideConfirmCubit>()
                                                .retry(),
                                            child: Text(
                                              context.l10n.confirmRetry,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_draft.scheduledFor != null)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                context.l10n.scheduledDeparture(
                                  scheduledTime(
                                    context,
                                    _draft.scheduledFor!,
                                  ),
                                ),
                                style: AppTextStyles.footnote,
                              ),
                            ),
                          const MwPaymentRow(),
                          if (loaded != null)
                            MwListRow(
                              icon: AppIcons.ticket,
                              subtitle: '',
                              title: loaded.promoQuote == null
                                  ? context.l10n.promoAdd
                                  : context.l10n.promoSelected(
                                      loaded.promoQuote!.code,
                                      Money(
                                        loaded.promoQuote!.discountMinor,
                                        loaded.fares.first.currency,
                                      ).toDisplayString(),
                                    ),
                              onTap: loaded.isRequesting
                                  ? null
                                  : () => showPromoSheet(context),
                              trailing: loaded.promoLoading
                                  ? const CircularProgressIndicator()
                                  : loaded.promoQuote == null
                                  ? null
                                  : IconButton(
                                      tooltip: context.l10n.promoRemove,
                                      icon: const Icon(AppIcons.close),
                                      onPressed: loaded.isRequesting
                                          ? null
                                          : context
                                                .read<RideConfirmCubit>()
                                                .removePromo,
                                    ),
                            ),
                          if (loaded?.promoFailure != null)
                            Text(
                              failureMessage(context, loaded!.promoFailure!),
                              style: AppTextStyles.footnote.copyWith(
                                color: context.colors.negative,
                              ),
                            ),
                          if (loaded?.requestFailure != null)
                            Text(
                              failureMessage(context, loaded!.requestFailure!),
                              style: AppTextStyles.footnote.copyWith(
                                color: context.colors.negative,
                              ),
                            ),
                          MwPrimaryButton(
                            isLoading: loaded?.isRequesting ?? false,
                            label: _draft.parcel != null
                                ? context.l10n.parcelRequest
                                : loaded == null
                                ? context.l10n.chooseRide
                                : _draft.scheduledFor != null
                                ? context.l10n.scheduleVehicle(
                                    _name(context, loaded.selected),
                                  )
                                : context.l10n.chooseVehicle(
                                    _name(context, loaded.selected),
                                  ),
                            onPressed: loaded == null || loaded.promoLoading
                                ? null
                                : context.read<RideConfirmCubit>().confirm,
                          ),
                          SizedBox(height: AppSpacing.xs),
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
    ),
  );
}
