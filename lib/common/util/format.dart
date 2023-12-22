import 'dart:math';

import 'package:appkit/common/constants/precision_constants.dart';
import 'package:appkit/common/constants/unicode_symbols.dart';
import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/common/types/decimal.dart';
import 'package:intl/intl.dart';

import 'parse.dart';

final _trailingZerosPattern = RegExp(r'(0+$)|([.,]0+$)');
final _stripTrailingFractionZerosPattern = RegExp(r'0+$');

final _decimalSeparatorPattern = RegExp(r'[.,]');

abstract class Format {
  static String stripTrailingZeros(double number, int fractionLength) {
    String string = number.toStringAsFixed(fractionLength);
    string = string.replaceAll(_stripTrailingFractionZerosPattern, '');
    if (string.endsWith('.') || string.endsWith(',')) {
      return string.substring(0, string.length - 1);
    }
    return string;
  }

  static String numberDecimal(
    Decimal number, {
    bool stripTrailingZeros = true,
    int fractionLength = PrecisionConstants.NUMBER,
  }) =>
      Format.number(
        number.toPrecision(fractionLength).toDouble(),
        stripTrailingZeros: stripTrailingZeros,
        fractionLength: fractionLength,
      );

  /// Format a number for display.
  static String number(
    double? number, {
    bool stripTrailingZeros = true,
    int fractionLength = PrecisionConstants.NUMBER,
  }) {
    return amount(
      number ?? 0.0,
      includeKztSymbol: false,
      stripTrailingZeros: stripTrailingZeros,
      fractionLength: fractionLength,
    );
  }

  static String? quantityDecimal(Decimal? quantity, [String? unitName]) {
    if (quantity == null) return null;
    return Format.quantity(
      quantity.toPrecision(PrecisionConstants.QUANTITY).toDouble(),
      unitName,
    );
  }

  /// Format a quantity value for display. Optional [unitName] will be appended.
  static String quantity(double quantity, [String? unitName]) {
    final formatted = amount(
      quantity,
      includeKztSymbol: false,
      stripTrailingZeros: true,
      fractionLength: PrecisionConstants.QUANTITY,
    );
    if (unitName != null) {
      return formatted + UnicodeSymbols.NBSP + unitName;
    }
    return formatted;
  }

  static percentDecimal(Decimal percent) =>
      Format.percent(percent.toPrecision(PrecisionConstants.PERCENT).toDouble());

  /// Format a percentage value. The '%' sign will be appended automatically.
  static String percent(double percent) {
    return number(
          percent,
          stripTrailingZeros: true,
          fractionLength: PrecisionConstants.PERCENT,
        ) +
        ' %';
  }

  static String amountDecimal(
    Decimal amount, {
    bool includeKztSymbol = true,
    bool stripTrailingZeros = false,
    int fractionLength = PrecisionConstants.AMOUNT,
  }) =>
      Format.amount(
        amount.toPrecision(fractionLength).toDouble(),
        includeKztSymbol: includeKztSymbol,
        stripTrailingZeros: stripTrailingZeros,
        fractionLength: fractionLength,
      );

  /// Format the given monetary amount.
  /// If [includeKztSymbol] is true, then a KZT symbol is appended to the result.
  /// If [stripTrailingZeros] is true, then non-significant trailing zeros are removed
  /// from the result.
  /// [fractionLength] specifies how many digits after the radix point are allowed at most.
  static String amount(
    double amount, {
    bool includeKztSymbol = true,
    bool stripTrailingZeros = false,
    int fractionLength = PrecisionConstants.AMOUNT,
  }) {
    final fractionalFactor = pow(10, fractionLength);
    final fractionalPart = amount * fractionalFactor - (amount.floor() * fractionalFactor);
    final absAmount = amount.abs();
    String formatted;
    if (fractionalPart > 0) {
      formatted = absAmount.toPrecision(fractionLength).toStringAsFixed(fractionLength);
    } else {
      formatted = absAmount.toStringAsFixed(0);
    }

    if (absAmount > 9999) {
      final result = formatted.split('').toList(growable: true);
      final startIndex =
          fractionalPart > 0 ? formatted.length - fractionLength - 1 : formatted.length;
      for (int i = startIndex - 3; i >= 0; i -= 3) {
        if (i > 0) {
          result.insert(i, UnicodeSymbols.NBSP);
        }
      }

      formatted = result.join('');
    }

    if (stripTrailingZeros && formatted.indexOf(_decimalSeparatorPattern) >= 0) {
      formatted = formatted.replaceAll(_trailingZerosPattern, '');
    }

    final sign = amount < 0 ? '-' : '';
    if (includeKztSymbol) {
      return '$sign$formatted${UnicodeSymbols.NBSP}${UnicodeSymbols.KZT}';
    } else {
      return '$sign$formatted';
    }
  }

  /// Format a potentially partial numeric input string.
  /// [fractionLength] specifies how many digits after the radix point are allowed at most.
  /// [maxLength] specifies the maximum length of the resulting string.
  static String? numericInput(
    String stringValue, {
    required int fractionLength,
    int? maxLength,
    bool stripTrailingZeros = true,
  }) {
    double? doubleValue = Parse.amount(stringValue);
    if (doubleValue != null) {
      // We format the integer part as usual, and apply custom formatting to the
      // fractional part.

      final integerPart = doubleValue.truncateToDouble();

      final formatted = amount(
        integerPart,
        includeKztSymbol: false,
        stripTrailingZeros: true,
        fractionLength: fractionLength,
      );

      String result;
      if (fractionLength > 0) {
        final indexOfDecimalSeparator = stringValue.indexOf(_decimalSeparatorPattern);
        if (indexOfDecimalSeparator >= 0) {
          result = formatted +
              normalizeDecimalPoint(stringValue.substring(
                indexOfDecimalSeparator,
                min(indexOfDecimalSeparator + fractionLength + 1, stringValue.length),
              ));
        } else {
          result = formatted;
        }
      } else {
        result = formatted;
      }

      if (maxLength != null && result.length > maxLength) {
        return null;
      }
      return result;
    }
    return null;
  }

  static final _dateWithWeekdayFormat = DateFormat('d MMMM, EEEE', 'ru');
  static final _dateFullWithWeekdayFormat = DateFormat('d MMMM yyyy, EEEE', 'ru');
  static final _dateHumanReadableFormat = DateFormat('d MMMM yyyy', 'ru');

  /// Format the given [dateTime] so that both date and time are shown.
  static String dateTime(DateTime? dateTime) {
    return dateTime != null ? '${date(dateTime)}, ${time(dateTime)}' : '';
  }

  /// Format the given DateTime in 'dd.MM.yyyy' format.
  static String date(DateTime? dateTime) {
    if (dateTime != null) {
      int year = dateTime.year;
      int month = dateTime.month;
      int day = dateTime.day;

      String monthString, dayString;

      if (month < 10) {
        monthString = '0$month';
      } else {
        monthString = month.toString();
      }

      if (day < 10) {
        dayString = '0$day';
      } else {
        dayString = day.toString();
      }

      return '$dayString.$monthString.$year';
    } else {
      return '';
    }
  }

  static String datePassed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final years = (difference.inDays / 365).floor();
    final months = (difference.inDays / 30).floor();
    final weeks = (difference.inDays / 7).floor();
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes < 1 ? 1 : difference.inMinutes;
    if (years >= 1) {
      return '$years y';
    } else if (months >= 1) {
      return '$months m';
    } else if (weeks >= 1) {
      return '$weeks w';
    } else if (days >= 1) {
      return '$days d';
    } else if (hours >= 1) {
      return '$hours h';
    }
    return '$minutes m';
  }

  static String metricsCount(int count) {
    if (count > 1000000) {
      return '${(count / 1000000).floor()}M';
    } else if (count > 1000) {
      return '${(count / 1000).floor()}K';
    } else {
      return count.toString();
    }
  }

  /// Format the given DateTime in 'HH:mm' format.
  static String time(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    String hourString;
    String minuteString;

    if (hour < 10) {
      hourString = '0$hour';
    } else {
      hourString = hour.toString();
    }

    if (minute < 10) {
      minuteString = '0$minute';
    } else {
      minuteString = minute.toString();
    }

    return '$hourString:$minuteString';
  }

  /// Format a duration value.
  static String duration(Duration duration) {
    if (duration < Duration.zero) {
      return Format.duration(Duration.zero);
    }

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String dateWithWeekday(DateTime dateTime) {
    final currentYear = DateTime.now().year;
    final isCurrentYear = dateTime.year == currentYear;
    return isCurrentYear
        ? _dateWithWeekdayFormat.format(dateTime)
        : _dateFullWithWeekdayFormat.format(dateTime);
  }

  static String dateHumanReadable(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateHumanReadableFormat.format(dateTime);
  }

  static String dateTimeHumanReadable(DateTime dateTime) {
    return '${dateHumanReadable(dateTime)}, ${time(dateTime)}';
  }

  static final _phoneNumberPattern = RegExp(r'^7\d{0,10}$');

  static String phoneNumberPartial(String input) {
    if (_phoneNumberPattern.hasMatch(input)) {
      final buffer = StringBuffer('+7 ');
      if (input.length > 1) {
        buffer
            .write('(${input.substring(1, min(4, input.length))}${input.length >= 4 ? ') ' : ''}');
      }
      if (input.length > 4) {
        buffer.write(input.substring(4, min(7, input.length)));
      }
      if (input.length > 7) {
        buffer.write('-${input.substring(7, min(9, input.length))}');
      }
      if (input.length > 9) {
        buffer.write('-${input.substring(9)}');
      }
      return buffer.toString();
    }
    return input;
  }

  /// Replace locale-specific decimal point character with standard period character ('.').
  static String normalizeDecimalPoint(String input) => input.replaceAll(',', '.');
}
