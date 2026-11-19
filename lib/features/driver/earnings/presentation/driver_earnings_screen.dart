import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/widgets/market_switcher.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_bar_chart.dart';
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({required this.uid, super.key});
  final String uid;
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark(),
    child: _Earnings(uid: uid),
  );
}

class _Earnings extends StatefulWidget {
  const _Earnings({required this.uid});
  final String uid;
  @override
  State<_Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<_Earnings> {
  String _market = 'JO';
  String get _currency => _market == 'PS' ? 'ILS' : 'JOD';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.earningsTitle)),
    body: BlocBuilder<EarningsScreenCubit, EarningsScreenState>(
      builder: (context, state) {
        final cubit = context.read<EarningsScreenCubit>();
        final selected = state.selectedEarnings?.forCurrency(_currency);
        return ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            MarketSwitcher(
              value: _market,
              onChanged: (v) => setState(() => _market = v),
            ),
            if (state.loading) const HistorySkeleton(),
            if (state.selected != null)
              Text(
                DateFormat.MMMEd(
                  Localizations.localeOf(context).toString(),
                ).format(state.selected!),
                style: AppTextStyles.footnote,
              ),
            if (selected != null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.l10n.fareAmount(
                    Money(
                      selected.totalMinor,
                      selected.currency,
                    ).toDisplayString(),
                  ),
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.tabular(AppTextStyles.largeTitle),
                ),
              ),
              Text(
                context.l10n.earningsTrips(selected.trips),
                style: AppTextStyles.body,
              ),
            ],
            if (state.days.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),
              EarningsBarChart(
                days: state.days.map((d) => d.forCurrency(_currency)).toList(),
                selected: state.selected,
                onSelected: cubit.selectDay,
              ),
              SizedBox(height: AppSpacing.xl),
              Text(context.l10n.earningsDayTrips, style: AppTextStyles.title2),
            ],
            if (state.loadingTrips) const HistorySkeleton(),
            if (!state.loading &&
                !state.loadingTrips &&
                state.days.isNotEmpty &&
                state.trips.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(context.l10n.earningsNoTrips),
              ),
            for (final ride in state.trips.where(
              (r) => r.currency == _currency,
            ))
              HistoryRideRow(
                ride: ride,
                driver: true,
                onTap: () => context.push('/driver/history/${ride.id}'),
              ),
            if (state.failure != null) ...[
              Text(failureMessage(context, state.failure!)),
              TextButton(
                onPressed: () => state.selected == null
                    ? cubit.load(widget.uid)
                    : cubit.selectDay(state.selected!),
                child: Text(context.l10n.retryLabel),
              ),
            ],
          ],
        );
      },
    ),
  );
}
