import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/widgets/mw_skeleton.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart';

class DriverEarningsPill extends StatelessWidget {
  const DriverEarningsPill({super.key});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/driver/earnings'),
    child: BlocBuilder<DriverEarningsCubit, DriverEarningsState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.earnings != null) ...[
            for (final currency in ['ILS', 'JOD'])
              Text(
                Money(
                  state.earnings!.forCurrency(currency).totalMinor,
                  currency,
                ).toDisplayString(),
                textDirection: TextDirection.ltr,
                style: AppTextStyles.tabular(AppTextStyles.headline),
              ),
          ] else if (state.failure != null)
            Text(
              failureMessage(context, state.failure!),
              style: AppTextStyles.footnote,
            )
          else
            MwSkeleton(width: AppSizes.iconCircle),
          Text(context.l10n.driverEarnings, style: AppTextStyles.footnote),
        ],
      ),
    ),
  );
}
