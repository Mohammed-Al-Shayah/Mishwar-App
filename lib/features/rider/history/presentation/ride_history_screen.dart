import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/rider_bottom_nav.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});
  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool? _upcoming;
  Future<void> _cancel(
    BuildContext context,
    RideHistoryCubit cubit,
    String id,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.scheduledCancelTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const Divider(),
              SizedBox(height: AppSpacing.md),
              MwPrimaryButton(
                label: context.l10n.scheduledCancelConfirm,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(context.l10n.scheduledKeep),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed ?? false) await cubit.cancelScheduled(id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const RiderBottomNav(index: 1),
    appBar: AppBar(title: Text(context.l10n.historyTitle)),
    body: BlocBuilder<RideHistoryCubit, RideHistoryState>(
      builder: (context, state) {
        final cubit = context.read<RideHistoryCubit>();
        final upcoming = _upcoming ?? state.scheduled.isNotEmpty;
        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (!upcoming &&
                  state.failure == null &&
                  metrics.maxScrollExtent > 0 &&
                  metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                unawaited(cubit.loadMore());
              }
              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(context.l10n.activityUpcoming),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(context.l10n.activityPast),
                    ),
                  ],
                  selected: {upcoming},
                  onSelectionChanged: (value) =>
                      setState(() => _upcoming = value.single),
                ),
                SizedBox(height: AppSpacing.md),
                if (upcoming) ...[
                  if (state.scheduled.isEmpty && state.scheduledFailure == null)
                    Text(
                      context.l10n.activityUpcomingEmpty,
                      style: AppTextStyles.body,
                    ),
                  for (final ride in state.scheduled)
                    HistoryRideRow(
                      ride: ride,
                      onTap: null,
                      trailing: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size(
                            AppSizes.buttonHeight,
                            AppSizes.buttonHeight,
                          ),
                        ),
                        onPressed: state.cancellingId != null
                            ? null
                            : () => _cancel(context, cubit, ride.id),
                        child: Text(context.l10n.scheduledCancel),
                      ),
                    ),
                ],
                if (upcoming && state.scheduledFailure != null)
                  Text(failureMessage(context, state.scheduledFailure!)),
                if (!upcoming) ...[
                  if (state.status == HistoryStatus.loading)
                    const HistorySkeleton(),
                  if (state.status == HistoryStatus.empty) ...[
                    Text(
                      context.l10n.historyEmptyTitle,
                      style: AppTextStyles.title2,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.historyEmptyBody,
                      style: AppTextStyles.body,
                    ),
                  ],
                  for (final ride in state.items)
                    HistoryRideRow(
                      ride: ride,
                      onTap: () => context.push('/rider/history/${ride.id}'),
                    ),
                  if (state.loadingMore) const HistorySkeleton(),
                  if (state.failure != null) ...[
                    Text(failureMessage(context, state.failure!)),
                    TextButton(
                      onPressed: state.items.isEmpty
                          ? cubit.refresh
                          : cubit.loadMore,
                      child: Text(context.l10n.retryLabel),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
