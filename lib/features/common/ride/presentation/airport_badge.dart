import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/features/common/ride/domain/entities/airport_details.dart';

class AirportBadge extends StatelessWidget {
  const AirportBadge({required this.airport, super.key});
  final AirportDetails airport;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Chip(label: Text(context.l10n.serviceAirport)),
      if (airport.flightNumber case final flight?)
        Text(
          flight,
          textDirection: TextDirection.ltr,
          style: AppTextStyles.subhead,
        ),
    ],
  );
}
