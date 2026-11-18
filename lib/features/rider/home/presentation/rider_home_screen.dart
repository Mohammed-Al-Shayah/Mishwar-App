import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_shadows.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/mw_search_pill.dart';
import 'package:mishwar/features/common/location/domain/entities/location_permission_status.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/history/presentation/rider_bottom_nav.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_state.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/home_shortcuts.dart';
import 'package:mishwar/features/rider/home/presentation/widgets/schedule_sheet.dart';
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({this.mapBuilder, super.key});
  final WidgetBuilder? mapBuilder;
  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen>
    with WidgetsBindingObserver {
  final GlobalKey<State<StatefulWidget>> _sheetKey = GlobalKey();
  DateTime? _scheduledFor;
  MwMapController? _map;
  double _sheetHeight = 0;
  bool _followedFirstFix = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(context.read<RiderHomeCubit>().start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<RiderHomeCubit>().start());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _firstFix(RiderHomeState state) {
    if (_followedFirstFix || _map == null || state.position == null) return;
    _followedFirstFix = true;
    unawaited(_map!.animateTo(state.position!));
  }

  void _measureSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final height = _sheetKey.currentContext?.size?.height;
      if (height != null && height != _sheetHeight) {
        setState(() => _sheetHeight = height);
      }
    });
  }

  Future<void> _searchDestination() async {
    final position = context.read<RiderHomeCubit>().state.position;
    final details = await context.push<PlaceDetails>(
      '/rider/search',
      extra: DestinationSearchParams(
        position: position,
        language: Localizations.localeOf(context).languageCode,
      ),
    );
    if (!mounted || details == null) return;
    await _chooseRide(details, fallback: position);
  }

  Future<void> _chooseRide(
    PlaceDetails details, {
    GeoPointValue? fallback,
  }) async {
    final pickup = context.read<RiderHomeCubit>().state.position ?? fallback;
    if (pickup == null) {
      // A real fix is required to create a ride draft.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationPermissionHint)),
      );
      return;
    }
    final label = context.l10n.currentLocation;
    await context.push<void>(
      '/rider/confirm',
      extra: RideDraft(
        scheduledFor: _scheduledFor,
        pickup: RideStop(name: label, address: label, location: pickup),
        dropoff: RideStop(
          name: details.name,
          address: details.address,
          location: details.location,
        ),
      ),
    );
  }

  Future<void> _addSaved(SavedPlaceLabel label) =>
      context.push<void>('/rider/places', extra: label);

  Future<void> _recenter() async {
    final cubit = context.read<RiderHomeCubit>();
    if (cubit.state.permission != LocationPermissionStatus.granted ||
        cubit.state.position == null) {
      await cubit.start();
    }
    if (!mounted) return;
    final point = cubit.state.position;
    if (cubit.state.permission == LocationPermissionStatus.granted &&
        point != null) {
      await _map?.animateTo(point);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<RiderHomeCubit, RiderHomeState>(
    listener: (context, state) => _firstFix(state),
    builder: (context, state) {
      _measureSheet();
      return Scaffold(
        bottomNavigationBar: const RiderBottomNav(index: 0),
        body: Stack(
          children: [
            Positioned.fill(
              child: MwMap(
                permissionGranted:
                    state.permission == LocationPermissionStatus.granted,
                padding: EdgeInsets.only(bottom: _sheetHeight),
                mapBuilder: widget.mapBuilder,
                onMapCreated: (controller) {
                  _map = controller;
                  _firstFix(context.read<RiderHomeCubit>().state);
                },
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: AppSpacing.md,
              child: SafeArea(
                child: MwMapFab(
                  icon: AppIcons.menu,
                  label: context.l10n.openMenu,
                ),
              ),
            ),
            PositionedDirectional(
              end: AppSpacing.md,
              bottom: _sheetHeight + AppSpacing.md,
              child: MwMapFab(
                icon: AppIcons.recenter,
                label: context.l10n.recenterMap,
                onPressed: _recenter,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                key: _sheetKey,
                decoration: BoxDecoration(
                  color: context.colors.sheet,
                  borderRadius: AppRadius.sheetBorder,
                  boxShadow: AppShadows.soft,
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        Text(
                          context.l10n.whereTo,
                          style: context.textStyles.headlineMedium,
                        ),
                        SizedBox(height: AppSpacing.md),
                        MwSearchPill(
                          onTap: _searchDestination,
                          scheduleLabel: _scheduledFor == null
                              ? null
                              : scheduledTime(context, _scheduledFor!),
                          onClearSchedule: _scheduledFor == null
                              ? null
                              : () => setState(() => _scheduledFor = null),
                          onSchedule: () async {
                            final time = await showScheduleSheet(
                              context,
                              _scheduledFor,
                            );
                            if (mounted && time != null) {
                              setState(() => _scheduledFor = time);
                            }
                          },
                        ),
                        SizedBox(height: AppSpacing.xs),
                        HomeShortcuts(
                          onPlace: (place) => unawaited(_chooseRide(place)),
                          onAddSaved: (label) => unawaited(_addSaved(label)),
                        ),
                        if (state.isLocating)
                          Padding(
                            padding: EdgeInsets.only(top: AppSpacing.sm),
                            child: LinearProgressIndicator(
                              color: context.colors.textPrimary,
                              backgroundColor: context.colors.fill,
                            ),
                          ),
                        if (!state.isLocating &&
                            state.permission !=
                                LocationPermissionStatus.granted) ...[
                          SizedBox(height: AppSpacing.sm),
                          Text(switch (state.permission) {
                            LocationPermissionStatus.deniedForever =>
                              context.l10n.locationForeverHint,
                            LocationPermissionStatus.serviceDisabled =>
                              context.l10n.locationServiceHint,
                            _ => context.l10n.locationPermissionHint,
                          }, style: context.textStyles.bodySmall),
                          SizedBox(height: AppSpacing.xs),
                          SizedBox(
                            height: AppSizes.buttonHeight,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: context.colors.fill,
                                foregroundColor: context.colors.textPrimary,
                              ),
                              onPressed: switch (state.permission) {
                                LocationPermissionStatus.deniedForever =>
                                  context
                                      .read<RiderHomeCubit>()
                                      .openAppSettings,
                                LocationPermissionStatus.serviceDisabled =>
                                  context
                                      .read<RiderHomeCubit>()
                                      .openLocationSettings,
                                _ => context.read<RiderHomeCubit>().start,
                              },
                              child: Text(switch (state.permission) {
                                LocationPermissionStatus.deniedForever =>
                                  context.l10n.openSettings,
                                LocationPermissionStatus.serviceDisabled =>
                                  context.l10n.enableLocation,
                                _ => context.l10n.allowLocation,
                              }),
                            ),
                          ),
                        ],
                        if (state.failure != null)
                          Text(
                            failureMessage(context, state.failure!),
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.negative,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
