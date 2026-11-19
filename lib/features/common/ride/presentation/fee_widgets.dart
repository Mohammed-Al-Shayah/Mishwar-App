import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

String feeAmount(BuildContext context, int minor, [String currency = 'JOD']) =>
    '\u2066${Money(minor, currency).toDisplayString()}\u2069';

class WaitingFeeNotice extends StatelessWidget {
  const WaitingFeeNotice({
    required this.arrivedAt,
    required this.now,
    this.currency = 'JOD',
    this.freeSeconds = 180,
    this.perMinuteMinor = 50,
    super.key,
  });
  final String currency;
  final int freeSeconds;
  final int perMinuteMinor;
  final DateTime arrivedAt;
  final DateTime now;
  @override
  Widget build(BuildContext context) {
    final remaining = (freeSeconds - now.difference(arrivedAt).inSeconds).clamp(
      0,
      freeSeconds,
    );
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final time = '${remaining ~/ 60}:$seconds';
    return Text(
      remaining > 0
          ? context.l10n.freeWaitingCountdown('\u2066$time\u2069')
          : context.l10n.waitingFeeRate(
              feeAmount(context, perMinuteMinor, currency),
            ),
      style: AppTextStyles.tabular(
        AppTextStyles.footnote,
      ).copyWith(color: context.colors.textSecondary),
    );
  }
}

class FareFeeRows extends StatelessWidget {
  const FareFeeRows({required this.ride, super.key});
  final RideEntity ride;
  @override
  Widget build(BuildContext context) {
    final rows = <(String, int)>[
      (context.l10n.feeWaiting, ride.fareWaitingFeeMinor),
      (context.l10n.feePreviousBalance, ride.farePreviousBalanceMinor),
      if (ride.status == RideStatus.cancelled)
        (context.l10n.feeCancellation, ride.fareCancellationFeeMinor),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (label, minor) in rows)
          if (minor > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: AppTextStyles.body)),
                  Text(
                    context.l10n.fareAmount(
                      Money(minor, ride.currency).toDisplayString(),
                    ),
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.tabular(AppTextStyles.headline),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
