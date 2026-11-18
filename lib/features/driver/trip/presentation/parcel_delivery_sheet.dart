import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_otp_input.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart';

Future<void> showParcelDeliverySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      builder: (_) => BlocProvider.value(
        value: context.read<DriverTripBloc>(),
        child: const ParcelDeliverySheet(),
      ),
    );

class ParcelDeliverySheet extends StatefulWidget {
  const ParcelDeliverySheet({super.key});
  @override
  State<ParcelDeliverySheet> createState() => _ParcelDeliverySheetState();
}

class _ParcelDeliverySheetState extends State<ParcelDeliverySheet> {
  String _code = '';
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DriverTripBloc, DriverTripState>(
        listener: (context, state) {
          if (state.phase != TripPhase.onTrip) Navigator.pop(context);
        },
        builder: (context, state) {
          final locked =
              (state.ride?.parcel?.codeAttempts ?? 0) >= 5 ||
              state.failure ==
                  const RideActionFailure(RideActionFailureReason.codeLocked);
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.parcelDeliver,
                    style: AppTextStyles.title1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(context.l10n.parcelEnterCode, style: AppTextStyles.body),
                  SizedBox(height: AppSpacing.md),
                  MwOtpInput(
                    length: 4,
                    enabled: !state.busy && !locked,
                    onChanged: (code) => setState(() => _code = code),
                  ),
                  SizedBox(height: AppSpacing.md),
                  if (locked || state.failure != null)
                    Text(
                      locked
                          ? context.l10n.parcelCodeLocked
                          : failureMessage(context, state.failure!),
                      style: AppTextStyles.footnote.copyWith(
                        color: context.colors.negative,
                      ),
                    ),
                  if (locked)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        unawaited(
                          context.push<void>(
                            '/driver/support/new?rideId=${state.ride!.id}',
                          ),
                        );
                      },
                      child: Text(context.l10n.parcelSupport),
                    ),
                  SizedBox(height: AppSpacing.md),
                  MwPrimaryButton(
                    label: context.l10n.parcelDeliver,
                    isLoading: state.busy,
                    onPressed: locked || _code.length != 4 || state.busy
                        ? null
                        : () => context.read<DriverTripBloc>().add(
                            CompletePressed(deliveryCode: _code),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
