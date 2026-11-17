// Jordan has used fixed UTC+3 since 2022. Calendar days are UTC values
// representing Amman dates, never device-local dates or instants.
const _ammanOffset = Duration(hours: 3);

DateTime ammanTime(DateTime instant) => instant.toUtc().add(_ammanOffset);

DateTime ammanDay(DateTime instant) {
  final local = ammanTime(instant);
  return DateTime.utc(local.year, local.month, local.day);
}

DateTime calendarDay(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day);

DateTime ammanDayStartUtc(DateTime day) =>
    calendarDay(day).subtract(_ammanOffset);

String earningsDayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';
