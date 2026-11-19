import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/charts/earnings_bar_painter.dart';
import 'package:mishwar/core/widgets/market_switcher.dart';
import 'package:mishwar/features/admin/domain/admin_reports.dart';
import 'package:mishwar/features/admin/presentation/report_download.dart';
import 'package:mishwar/features/admin/presentation/reports_cubit.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});
  List<String> _headings(BuildContext c) => [
    c.l10n.reportsDay,
    c.l10n.reportsRides,
    c.l10n.reportsCompleted,
    c.l10n.reportsRevenue,
    c.l10n.reportsDiscount,
    c.l10n.reportsRiderCancel,
    c.l10n.reportsDriverCancel,
    c.l10n.reportsSystemCancel,
    c.l10n.reportsNoDrivers,
    c.l10n.reportsPromoUses,
    c.l10n.reportsParcels,
    c.l10n.reportsAirport,
    c.l10n.reportsScheduled,
  ];
  @override
  Widget build(BuildContext context) => BlocBuilder<ReportsCubit, ReportsState>(
    builder: (context, state) => ListView(
      children: [
        MarketSwitcher(
          value: state.market,
          enabled: !state.loading,
          onChanged: (m) => context.read<ReportsCubit>().load(null, m),
        ),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SegmentedButton<int>(
              segments: [
                for (final d in [7, 30, 90])
                  ButtonSegment(
                    value: d,
                    label: Text(context.l10n.reportsRange('$d')),
                  ),
              ],
              selected: {state.days},
              onSelectionChanged: (v) =>
                  context.read<ReportsCubit>().load(v.single),
            ),
            OutlinedButton(
              onPressed: state.data == null || state.loading
                  ? null
                  : () => downloadReport(
                      state.data!.csv(_headings(context)),
                      'mishwar-${state.data!.days.first.day}-'
                      '${state.data!.days.last.day}.csv',
                    ),
              child: Text(context.l10n.reportsExport),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(context.l10n.reportsTimezone, style: AppTextStyles.footnote),
        if (state.loading) const LinearProgressIndicator(),
        if (state.failure != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.adminError,
                  style: TextStyle(color: context.colors.negative),
                ),
              ),
              TextButton(
                onPressed: () => context.read<ReportsCubit>().load(),
                child: Text(context.l10n.adminRetry),
              ),
            ],
          ),
        if (state.data case final data?) ...[
          SizedBox(height: AppSpacing.xl),
          if (data.days.isNotEmpty)
            Text(
              '${data.days.first.day} → ${data.days.last.day}',
              style: AppTextStyles.footnote,
            ),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.xl,
            children: [
              for (final tile in [
                (context.l10n.reportsRides, '${data.total('requested')}'),
                (
                  context.l10n.reportsCompletedRate,
                  '${data.completionRate.toStringAsFixed(1)}%',
                ),
                (
                  context.l10n.reportsRevenue,
                  Money(
                    data.total('revenueMinor'),
                    data.currency,
                  ).toDisplayString(),
                ),
                (
                  context.l10n.reportsAverage,
                  Money(
                    (data.averageFare * Money.scale(data.currency)).round(),
                    data.currency,
                  ).toDisplayString(),
                ),
                (
                  context.l10n.reportsCancellationRate,
                  '${data.cancellationRate.toStringAsFixed(1)}%',
                ),
                (context.l10n.reportsPromoUses, '${data.total('promoUses')}'),
              ])
                SizedBox(
                  width: AdminSizes.field * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tile.$1, style: AppTextStyles.subhead),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          tile.$2,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.tabular(
                            AppTextStyles.largeTitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          ReportsChart(data: data),
          SizedBox(height: AppSpacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: AdminSizes.row,
              dataRowMaxHeight: AdminSizes.row,
              columns: [
                for (final h in _headings(context)) DataColumn(label: Text(h)),
              ],
              rows: [
                for (final d in data.days)
                  DataRow(
                    cells: [
                      for (final v in [
                        d.day,
                        '${d.count('requested')}',
                        '${d.count('completed')}',
                        Money(
                          d.count('revenueMinor'),
                          data.currency,
                        ).toDisplayString(),
                        Money(
                          d.count('discountMinor'),
                          data.currency,
                        ).toDisplayString(),
                        '${d.count('cancelledByRider')}',
                        '${d.count('cancelledByDriver')}',
                        '${d.count('cancelledBySystem')}',
                        '${d.count('noDrivers')}',
                        '${d.count('promoUses')}',
                        '${d.count('parcels')}',
                        '${d.count('airport')}',
                        '${d.count('scheduled')}',
                      ])
                        DataCell(Text(v, textDirection: TextDirection.ltr)),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(context.l10n.reportsTopPromos, style: AppTextStyles.title2),
          if (data.topPromos.isEmpty) Text(context.l10n.adminEmpty),
          for (final p in data.topPromos.take(10))
            ListTile(
              title: Text(p.key),
              trailing: Text('${p.value}', style: AppTextStyles.headline),
            ),
        ],
      ],
    ),
  );
}

class ReportsChart extends StatelessWidget {
  const ReportsChart({required this.data, super.key});
  final ReportData data;
  @override
  Widget build(BuildContext context) {
    final maxRides = data.days.fold<int>(
      0,
      (m, d) => d.count('requested') > m ? d.count('requested') : m,
    );
    final maxRevenue = data.days.fold<int>(
      0,
      (m, d) => d.count('revenueMinor') > m ? d.count('revenueMinor') : m,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.reportsChart, style: AppTextStyles.title2),
        Text(
          context.l10n.reportsScale(
            '$maxRides',
            Money(maxRevenue, data.currency).toDisplayString(),
          ),
          style: AppTextStyles.footnote,
        ),
        SizedBox(height: AppSpacing.md),
        Semantics(
          label: data.days
              .map(
                (d) => context.l10n.reportsChartDay(
                  d.day,
                  '${d.count('requested')}',
                  Money(
                    d.count('revenueMinor'),
                    data.currency,
                  ).toDisplayString(),
                ),
              )
              .join('; '),
          child: SizedBox(
            height: AppSizes.earningsChartHeight,
            child: CustomPaint(
              painter: ReportsPainter(
                days: data.days,
                maxRides: maxRides,
                maxRevenue: maxRevenue,
                barColor: context.colors.textSecondary,
                lineColor: context.colors.textPrimary,
                stroke: AppSizes.divider * 4,
                gap: AppSpacing.xxs,
              ),
            ),
          ),
        ),
        if (data.days.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.days.first.day, style: AppTextStyles.caption),
              Text(data.days.last.day, style: AppTextStyles.caption),
            ],
          ),
      ],
    );
  }
}

class ReportsPainter extends CustomPainter {
  const ReportsPainter({
    required this.days,
    required this.maxRides,
    required this.maxRevenue,
    required this.barColor,
    required this.lineColor,
    required this.stroke,
    required this.gap,
  });
  final List<ReportDay> days;
  final int maxRides;
  final int maxRevenue;
  final Color barColor;
  final Color lineColor;
  final double stroke;
  final double gap;
  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final step = size.width / days.length;
    final path = Path();
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      if (d.count('requested') > 0) {
        canvas
          ..save()
          ..translate(i * step + gap / 2, 0);
        EarningsBarPainter(
          fraction: maxRides == 0 ? 0 : d.count('requested') / maxRides,
          color: barColor,
          minimumHeight: 0,
        ).paint(canvas, Size((step - gap).clamp(stroke, step), size.height));
        canvas.restore();
      }
      final x = (i + 0.5) * step;
      final y =
          size.height -
          (maxRevenue == 0 ? 0 : d.count('revenueMinor') / maxRevenue) *
              (size.height - stroke);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(ReportsPainter old) =>
      old.days != days ||
      old.maxRides != maxRides ||
      old.maxRevenue != maxRevenue ||
      old.barColor != barColor ||
      old.lineColor != lineColor ||
      old.stroke != stroke ||
      old.gap != gap;
}
