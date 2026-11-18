import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

/// Display defaults only. The completed fare always comes from the server.
abstract final class WaitingDisplay {
  static const freeSeconds = 180;
  static const perMinuteFils = 50;
  static int feeFils(Duration elapsed) =>
      ((elapsed.inMilliseconds - freeSeconds * 1000) / 60000).ceil().clamp(
        0,
        999999,
      ) *
      perMinuteFils;
}

String feeAmount(BuildContext context, int fils) =>
    '\u2066${context.l10n.fareJod(Money(fils).toJodString())}\u2069';

class WaitingFeeNotice extends StatelessWidget {
  const WaitingFeeNotice({
    required this.arrivedAt,
    required this.now,
    super.key,
  });
  final DateTime arrivedAt;
  final DateTime now;
  @override
  Widget build(BuildContext context) {
    final remaining =
        (WaitingDisplay.freeSeconds - now.difference(arrivedAt).inSeconds)
            .clamp(0, WaitingDisplay.freeSeconds);
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final time = '${remaining ~/ 60}:$seconds';
    return Text(
      remaining > 0
          ? context.l10n.freeWaitingCountdown('\u2066$time\u2069')
          : context.l10n.waitingFeeRate(
              feeAmount(context, WaitingDisplay.perMinuteFils),
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
      (context.l10n.feeWaiting, ride.fareWaitingFeeFils),
      (context.l10n.feePreviousBalance, ride.farePreviousBalanceFils),
      if (ride.status == RideStatus.cancelled)
        (context.l10n.feeCancellation, ride.fareCancellationFeeFils),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (label, fils) in rows)
          if (fils > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: AppTextStyles.body)),
                  Text(
                    context.l10n.fareJod(Money(fils).toJodString()),
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
