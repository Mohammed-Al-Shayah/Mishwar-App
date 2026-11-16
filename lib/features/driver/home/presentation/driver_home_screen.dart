import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as offer;
import 'package:mishwar/features/driver/offer/presentation/driver_offer_sheet.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({required this.uid, this.mapBuilder, super.key});
  final String uid;
  final WidgetBuilder? mapBuilder;
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark(),
    child: _DriverHome(uid: uid, mapBuilder: mapBuilder),
  );
}

class _DriverHome extends StatefulWidget {
  const _DriverHome({required this.uid, this.mapBuilder});
  final String uid;
  final WidgetBuilder? mapBuilder;
  @override
  State<_DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<_DriverHome> {
  MwMapController? _map;
  void _recenter() {
    final fix = context.read<DriverPresenceBloc>().state.lastFix;
    if (fix != null) unawaited(_map?.animateTo(fix.point));
  }

  void _online() {
    unawaited(HapticFeedback.lightImpact());
    context.read<DriverPresenceBloc>().add(const GoOnlinePressed());
  }

  Future<void> _offline() async {
    unawaited(HapticFeedback.lightImpact());
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.driverStopConfirm,
                style: context.textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.driverStop),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.driverKeepOnline),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      context.read<DriverPresenceBloc>().add(const GoOfflinePressed());
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<DriverPresenceBloc, DriverPresenceState>(
    listenWhen: (previous, current) =>
        previous.lastFix == null && current.lastFix != null,
    listener: (_, _) => _recenter(),
    builder: (context, state) {
      final l10n = context.l10n;
      final offerState = context.watch<offer.DriverOfferBloc>().state;
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: MwMap(
                mapBuilder: widget.mapBuilder,
                permissionGranted:
                    state.lastFix != null &&
                    state.status != PresenceStatus.permissionDenied,
                padding: EdgeInsets.only(bottom: AppSizes.driverBarClearance),
                onMapCreated: (map) {
                  _map = map;
                  _recenter();
                },
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.sheet,
                      borderRadius: AppRadius.pillBorder,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.driverEarningsAmount,
                            textDirection: TextDirection.ltr,
                            style: context.textStyles.titleLarge?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            l10n.driverEarnings,
                            style: context.textStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!offerState.showing)
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MwMapFab(
                            icon: AppIcons.recenter,
                            label: l10n.recenterMap,
                            onPressed: state.lastFix == null ? null : _recenter,
                          ),
                        ],
                      ),
                    ),
                  if (!state.isOnline && !offerState.showing)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xl),
                      child: SizedBox(
                        width: AppSizes.driverStart,
                        height: AppSizes.driverStart,
                        child: FilledButton(
                          key: const Key('driver_start'),
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: state.busy ? null : _online,
                          child: state.busy
                              ? const CircularProgressIndicator()
                              : Text(l10n.driverStart),
                        ),
                      ),
                    ),
                  const DriverOfferOverlay(),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.colors.sheet,
                      borderRadius: AppRadius.sheetBorder,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                if (state.isOnline) ...[
                                  const _OnlineDot(),
                                  SizedBox(width: AppSpacing.xs),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.isOnline
                                            ? l10n.driverOnline
                                            : l10n.driverOffline,
                                        style: context.textStyles.titleMedium,
                                      ),
                                      Text(
                                        state.isOnline
                                            ? l10n.driverOnlineHint
                                            : l10n.driverOfflineHint,
                                        style: context.textStyles.bodySmall
                                            ?.copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (state.isOnline && !offerState.showing) ...[
                                  SizedBox(width: AppSpacing.xs),
                                  FilledButton.tonal(
                                    key: const Key('driver_stop'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size(
                                        0,
                                        AppSizes.buttonHeight,
                                      ),
                                      backgroundColor: context.colors.fill,
                                      foregroundColor:
                                          context.colors.textPrimary,
                                    ),
                                    onPressed: state.canGoOffline && !state.busy
                                        ? _offline
                                        : null,
                                    child: state.busy
                                        ? const CircularProgressIndicator()
                                        : Text(l10n.driverStop),
                                  ),
                                ],
                              ],
                            ),
                            if (state.status ==
                                PresenceStatus.permissionDenied) ...[
                              Text(
                                l10n.locationPermissionHint,
                                style: context.textStyles.bodySmall,
                              ),
                              TextButton(
                                onPressed: () => context
                                    .read<DriverPresenceBloc>()
                                    .openSettings(),
                                child: Text(l10n.openSettings),
                              ),
                            ],
                            if (state.isOnline &&
                                (state.status ==
                                        PresenceStatus.permissionDenied ||
                                    state.status == PresenceStatus.failure))
                              TextButton(
                                onPressed: _online,
                                child: Text(l10n.retryLabel),
                              ),
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
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _OnlineDot extends StatefulWidget {
  const _OnlineDot();
  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppSizes.driverPulseDuration,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.5, end: 1).animate(_controller),
    child: Container(
      width: AppSizes.timelineMark,
      height: AppSizes.timelineMark,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.positive,
      ),
    ),
  );
}
