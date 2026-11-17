import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart';
import 'package:mishwar/features/rider/history/presentation/rider_bottom_nav.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const RiderBottomNav(index: 1),
    appBar: AppBar(title: Text(context.l10n.historyTitle)),
    body: BlocBuilder<RideHistoryCubit, RideHistoryState>(
      builder: (context, state) {
        final cubit = context.read<RideHistoryCubit>();
        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (state.failure == null &&
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
            ),
          ),
        );
      },
    ),
  );
}
