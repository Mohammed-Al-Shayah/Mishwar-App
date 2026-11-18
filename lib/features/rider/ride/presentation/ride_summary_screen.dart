import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/trip_stops.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/rating/presentation/rating_exit.dart';
import 'package:mishwar/features/common/rating/presentation/rating_form.dart';
import 'package:mishwar/features/common/ride/presentation/promo_discount_row.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({super.key});
  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RideTrackingBloc>().add(const RideTrackingStarted());
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light(),
    child: Builder(builder: _buildSummary),
  );
  Widget _buildSummary(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<RideTrackingBloc, RideTrackingState>(
        builder: (context, state) {
          final ride = state.ride;
          if (ride == null) {
            return Center(
              child: state.failure == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(failureMessage(context, state.failure!)),
                        TextButton(
                          onPressed: () => context.read<RideTrackingBloc>().add(
                            const RideTrackingStarted(),
                          ),
                          child: Text(context.l10n.confirmRetry),
                        ),
                      ],
                    ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.l10n.riderCompleted, style: AppTextStyles.title1),
                SizedBox(height: AppSpacing.xl),
                // Price reads LTR but sits at the layout's start edge.
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.l10n.tripPrice(
                      Money(
                        ride.fareFinalFils ?? ride.fareEstimatedFils,
                      ).toJodString(),
                    ),
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.tabular(AppTextStyles.largeTitle),
                  ),
                ),
                PromoDiscountRow(ride: ride),
                Text(context.l10n.riderCashNote, style: AppTextStyles.body),
                SizedBox(height: AppSpacing.xl),
                TripStops(ride: ride),
                SizedBox(height: AppSpacing.xl),
                RatingExit(
                  child: RatingForm(
                    name: ride.driverInfo?.name ?? '',
                    onDone: () => RatingExit.finish(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
