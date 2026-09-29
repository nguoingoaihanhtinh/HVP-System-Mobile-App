/// Time source for the mock backend.
///
/// The background jobs (UC15 expiry, UC16 inactive) and the comeback rule
/// (UC17) depend on "today". The demo screen and the tests move the clock
/// instead of waiting for real days to pass.
abstract class Clock {
  DateTime now();
}

class SimulatedClock implements Clock {
  SimulatedClock({DateTime? base}) : _base = base;

  final DateTime? _base;
  Duration offset = Duration.zero;

  @override
  DateTime now() => (_base ?? DateTime.now()).add(offset);

  void advance(Duration duration) => offset += duration;

  void reset() => offset = Duration.zero;
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Whole calendar days from [from] to [to] (negative when [to] is earlier).
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// Same day [months] later, clamped to the last day of the target month.
DateTime addMonths(DateTime value, int months) {
  final monthIndex = value.month - 1 + months;
  final year = value.year + (monthIndex / 12).floor();
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = value.day > lastDay ? lastDay : value.day;
  return DateTime(year, month, day, value.hour, value.minute, value.second);
}

String ymd(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String dmy(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
