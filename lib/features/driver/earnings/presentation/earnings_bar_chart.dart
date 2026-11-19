import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/charts/earnings_bar_painter.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/driver/earnings/domain/daily_earnings.dart';

class EarningsBarChart extends StatelessWidget {
  const EarningsBarChart({
    required this.days,
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final List<DailyEarnings> days;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;
  @override
  Widget build(BuildContext context) {
    final maximum = days.fold<int>(
      0,
      (max, d) => d.totalMinor > max ? d.totalMinor : max,
    );
    final locale = Localizations.localeOf(context).toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in days)
          Expanded(
            child: Semantics(
              selected: day.day == selected,
              button: true,
              label: context.l10n.earningsBarLabel(
                DateFormat.MMMEd(locale).format(day.day),
                Money(day.totalMinor, day.currency).toDisplayString(),
              ),
              child: InkWell(
                onTap: () => onSelected(day.day),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  child: Column(
                    children: [
                      Text(
                        Money(day.totalMinor, day.currency).toDisplayString(),
                        textDirection: TextDirection.ltr,
                        style: AppTextStyles.tabular(AppTextStyles.caption),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: AppSizes.earningsChartHeight,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: EarningsBarPainter(
                            fraction: maximum == 0
                                ? 0
                                : day.totalMinor / maximum,
                            color: day.day == selected
                                ? context.colors.textPrimary
                                : context.colors.textSecondary,
                            minimumHeight: AppSizes.divider,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        // Day of month: Arabic weekday names all start "ال".
                        DateFormat.d(locale).format(day.day),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
