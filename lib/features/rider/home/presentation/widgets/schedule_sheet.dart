import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';

String scheduledTime(BuildContext context, DateTime time) => DateFormat.EEEE(
  Localizations.localeOf(context).toString(),
).add_jm().format(time.toLocal());

Future<DateTime?> showScheduleSheet(BuildContext context, DateTime? initial) =>
    showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => ScheduleSheet(initial: initial),
    );

class ScheduleSheet extends StatefulWidget {
  const ScheduleSheet({this.initial, super.key});
  final DateTime? initial;
  @override
  State<ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<ScheduleSheet> {
  late final DateTime _now = DateTime.now();
  late final DateTime _maximum = _now.add(const Duration(days: 30));
  DateTime get _minimum {
    final time = DateTime.now().add(const Duration(minutes: 30));
    const interval = 5 * 60 * 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      ((time.millisecondsSinceEpoch + interval - 1) ~/ interval) * interval,
    );
  }

  late DateTime _selected = _clamp(widget.initial ?? _minimum);

  DateTime _clamp(DateTime time) {
    final rounded = DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      ((time.minute + 4) ~/ 5) * 5,
    );
    if (rounded.isBefore(_minimum)) return _minimum;
    if (rounded.isAfter(_maximum)) {
      return DateTime(
        _maximum.year,
        _maximum.month,
        _maximum.day,
        _maximum.hour,
        (_maximum.minute ~/ 5) * 5,
      );
    }
    return rounded;
  }

  void _day(DateTime day) => setState(() {
    _selected = _clamp(
      DateTime(day.year, day.month, day.day, _selected.hour, _selected.minute),
    );
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizes.grabberWidth,
                height: AppSizes.grabberHeight,
                decoration: BoxDecoration(
                  color: context.colors.grabber,
                  borderRadius: AppRadius.pillBorder,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.scheduleTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.title1,
            ),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(
                          i == 0
                              ? context.l10n.scheduleToday
                              : i == 1
                              ? context.l10n.scheduleTomorrow
                              : DateFormat.MMMEd(
                                  locale,
                                ).format(_now.add(Duration(days: i))),
                        ),
                        selected: DateUtils.isSameDay(
                          _selected,
                          _now.add(Duration(days: i)),
                        ),
                        onSelected: (_) => _day(_now.add(Duration(days: i))),
                      ),
                    ),
                  ActionChip(
                    label: Text(context.l10n.scheduleOtherDate),
                    onPressed: () async {
                      final day = await showDatePicker(
                        context: context,
                        initialDate: _selected,
                        firstDate: _now,
                        lastDate: _maximum,
                      );
                      if (mounted && day != null) _day(day);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              DateFormat.yMMMMEEEEd(locale).format(_selected),
              style: AppTextStyles.headline,
            ),
            SizedBox(
              height: AppSizes.scheduleWheelHeight,
              // The wheel uses the app font (IBM Plex) and colours instead of
              // the iOS system font, so it matches the rest of the sheet.
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: AppTextStyles.title2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  key: ValueKey(DateUtils.dateOnly(_selected)),
                  mode: CupertinoDatePickerMode.time,
                  minuteInterval: 5,
                  initialDateTime: _selected,
                  minimumDate: DateUtils.isSameDay(_selected, _minimum)
                      ? _minimum
                      : null,
                  maximumDate: DateUtils.isSameDay(_selected, _maximum)
                      ? _maximum
                      : null,
                  onDateTimeChanged: (time) =>
                      setState(() => _selected = _clamp(time)),
                ),
              ),
            ),
            Text(context.l10n.scheduleWindow, style: AppTextStyles.footnote),
            SizedBox(height: AppSpacing.md),
            MwPrimaryButton(
              label: context.l10n.scheduleConfirm,
              onPressed: () => Navigator.of(context).pop(_clamp(_selected)),
            ),
          ],
        ),
      ),
    );
  }
}
