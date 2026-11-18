import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/map/mw_pin_label.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/rider/pickup/presentation/pickup_confirm_cubit.dart';

class PickupConfirmScreen extends StatefulWidget {
  const PickupConfirmScreen({this.mapBuilder, super.key});
  final WidgetBuilder? mapBuilder;
  @override
  State<PickupConfirmScreen> createState() => _PickupConfirmScreenState();
}

class _PickupConfirmScreenState extends State<PickupConfirmScreen> {
  MwMapController? _controller;
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(
      context.read<PickupConfirmCubit>().start(
        lang: Localizations.localeOf(context).languageCode,
        fallback: context.l10n.pickupGeneric,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<PickupConfirmCubit, PickupConfirmState>(
    builder: (context, state) {
      final cubit = context.read<PickupConfirmCubit>();
      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final sheetHeight =
                constraints.maxHeight * AppSizes.pickupSheetFraction;
            return Stack(
              fit: StackFit.expand,
              children: [
                MwMap(
                  mapBuilder: widget.mapBuilder,
                  initialTarget: state.stop.location,
                  padding: EdgeInsets.only(bottom: sheetHeight),
                  onMapCreated: (c) => _controller = c,
                  onCameraMoveStarted: cubit.moving,
                  onCameraMove: cubit.cameraMoved,
                  onCameraIdle: cubit.cameraIdle,
                  circles: {
                    for (final p in state.suggestions)
                      Circle(
                        circleId: CircleId(p.id),
                        center: LatLng(p.location.lat, p.location.lng),
                        radius: AppSizes.pickupSuggestionRadius,
                        fillColor: context.colors.textInactive,
                        strokeWidth: 0,
                        consumeTapEvents: true,
                        onTap: () {
                          cubit.select(p);
                          unawaited(_controller?.animateTo(p.location));
                        },
                      ),
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: sheetHeight,
                  child: IgnorePointer(
                    child: Center(
                      child: _PickupPin(
                        moving: state.phase == PickupPhase.moving,
                        label: state.busy
                            ? context.l10n.pickupGeneric
                            : state.stop.name,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: MwMapFab(
                          icon: AppIcons.back,
                          label: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: sheetHeight,
                  child: BottomSheet(
                    onClosing: () {},
                    enableDrag: false,
                    builder: (context) => SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      context.l10n.pickupTitle,
                                      style: AppTextStyles.title1,
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    if (state.busy) ...[
                                      MwSkeleton(width: AppSizes.skeletonTitle),
                                      SizedBox(height: AppSpacing.xs),
                                      MwSkeleton(
                                        width: AppSizes.skeletonSubtitle,
                                      ),
                                    ] else ...[
                                      Text(
                                        state.stop.name,
                                        style: AppTextStyles.headline,
                                      ),
                                      Text(
                                        state.stop.address,
                                        style: AppTextStyles.footnote.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      context.l10n.pickupHint,
                                      style: AppTextStyles.footnote.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    if (state.farFromDevice)
                                      Text(
                                        context.l10n.pickupFarWarning,
                                        style: AppTextStyles.footnote.copyWith(
                                          color: context.colors.negative,
                                        ),
                                      ),
                                    Wrap(
                                      spacing: AppSpacing.sm,
                                      children: [
                                        for (final p in state.suggestions)
                                          ActionChip(
                                            label: Text(
                                              p.name,
                                              style: AppTextStyles.subhead,
                                            ),
                                            onPressed: () {
                                              cubit.select(p);
                                              unawaited(
                                                _controller?.animateTo(
                                                  p.location,
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            MwPrimaryButton(
                              label: context.l10n.pickupConfirm,
                              onPressed:
                                  state.busy || state.phase == PickupPhase.idle
                                  ? null
                                  : () => context.pop<RideStop>(state.stop),
                            ),
                            SizedBox(height: AppSpacing.sm),
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

class _PickupPin extends StatelessWidget {
  const _PickupPin({required this.moving, required this.label});
  final bool moving;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppSizes.skeletonSubtitle,
    height: AppSizes.pickupShadow,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: AppSizes.pickupShadow,
          height: AppSizes.pickupShadow,
          decoration: BoxDecoration(
            color: context.colors.textInactive,
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          bottom: AppSizes.pickupShadow + AppSpacing.xs,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppSizes.pinLiftDuration,
            transform: Matrix4.translationValues(
              0,
              moving ? -AppSizes.pickupPinLift : 0,
              0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MwPinLabel(label: label),
                SizedBox(height: AppSpacing.xs),
                Container(
                  width: AppSizes.pinSize + AppSizes.pinStroke * 2,
                  height: AppSizes.pinSize + AppSizes.pinStroke * 2,
                  padding: EdgeInsets.all(AppSizes.pinStroke),
                  color: context.colors.surface,
                  child: ColoredBox(
                    color: context.colors.textPrimary,
                    child: Center(
                      child: Container(
                        width: AppSizes.pinInner,
                        height: AppSizes.pinInner,
                        color: context.colors.surface,
                      ),
                    ),
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
