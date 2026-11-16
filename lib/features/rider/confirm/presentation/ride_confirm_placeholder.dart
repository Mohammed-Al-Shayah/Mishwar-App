import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';

/// T2.4 replaces this with route, vehicle and fare selection.
class RideConfirmPlaceholder extends StatelessWidget {
  const RideConfirmPlaceholder({required this.draft, super.key});
  final RideDraft draft;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.chooseRide),
      leading: BackButton(onPressed: () => context.pop()),
    ),
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(draft.pickup.name, style: context.textStyles.titleMedium),
          Text(draft.pickup.address, style: context.textStyles.bodySmall),
          SizedBox(height: AppSpacing.md),
          Text(draft.dropoff.name, style: context.textStyles.titleMedium),
          Text(draft.dropoff.address, style: context.textStyles.bodySmall),
        ],
      ),
    ),
  );
}
