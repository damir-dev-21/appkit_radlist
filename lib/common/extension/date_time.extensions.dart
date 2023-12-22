extension DateTimeExtension on DateTime {
  DateTime get atStartOfDay {
    return DateTime(year, month, day);
  }

  DateTime get atEndOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }

  bool isOnSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isOnDifferentDay(DateTime other) => !isOnSameDay(other);
}
