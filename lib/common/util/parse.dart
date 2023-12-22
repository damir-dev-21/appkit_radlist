import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/common/types/decimal.dart';
import 'package:appkit/data/json_converter.dart';

import 'format.dart';
import '../constants/unicode_symbols.dart';

const _DEFAULT_SERVER_ZONE_OFFSET = 6;

/// Various utilities for safe JSON parsing.
class Parse {
  /// Parse a value that is formatted as an amount, with thousands separators and
  /// possibly a comma instead of the radix point.
  static double? amount(String input) {
    String processed = input;
    if (processed.indexOf(' ') >= 0) {
      processed = processed.replaceAll(' ', '');
    }
    if (processed.indexOf(UnicodeSymbols.NBSP) >= 0) {
      processed = processed.replaceAll(UnicodeSymbols.NBSP, '');
    }
    if (processed.indexOf(',') >= 0) {
      processed = Format.normalizeDecimalPoint(processed);
    }

    return double.tryParse(processed);
  }

  /// Parse a String or int date. If [input] doesn't contain information about time zone,
  /// [serverZoneOffset] with the default value of [_DEFAULT_SERVER_ZONE_OFFSET] will be used
  /// to restore time to +00 value before adjusting it to device's local time.
  static DateTime? date(
    dynamic input, {
    int serverZoneOffset = _DEFAULT_SERVER_ZONE_OFFSET,
  }) {
    if (input != null) {
      if (input is String) {
        if (input.contains('T')) {
          return DateTime.tryParse(input)?.add(DateTime.now().timeZoneOffset);
        } else {
          return DateTime.tryParse(input)
              ?.add(DateTime.now().timeZoneOffset - Duration(hours: serverZoneOffset));
        }
      } else if (input is int) {
        return DateTime.fromMillisecondsSinceEpoch(input);
      }
    }

    return null;
  }

  static int integer(dynamic input, {int defaultValue = -1}) {
    if (input != null) {
      if (input is String) {
        return int.tryParse(input) ?? defaultValue;
      } else if (input is num) {
        return input.toInt();
      }
    }
    return defaultValue;
  }

  static int? integerOrNull(dynamic input) {
    if (input != null) {
      if (input is String) {
        return int.tryParse(input);
      } else if (input is num) {
        return input.toInt();
      }
    }
    return null;
  }

  static double float(dynamic input, {double defaultValue = 0.0}) {
    if (input != null) {
      if (input is String) {
        return double.tryParse(input) ?? defaultValue;
      } else if (input is num) {
        return input.toDouble();
      }
    }

    return defaultValue;
  }

  static Decimal decimal(dynamic input, {Decimal? defaultValue}) {
    if (input != null) {
      if (input is String) {
        return Decimal.tryParse(input) ?? defaultValue ?? Decimal.zero;
      } else if (input is num) {
        return input.toDecimal();
      }
    }
    return defaultValue ?? Decimal.zero;
  }

  static Decimal? decimalOrNull(dynamic input) {
    if (input != null) {
      if (input is String) {
        return Decimal.tryParse(input);
      } else if (input is num) {
        return input.toDecimal();
      }
    }
    return null;
  }

  static bool boolean(dynamic input, {bool defaultValue = false}) {
    if (input != null) {
      if (input is bool) {
        return input;
      } else if (input is num) {
        return input > 0;
      } else if (input is String) {
        return input == 'true';
      }
    }
    return defaultValue;
  }

  static String string(dynamic input, {String defaultValue = ''}) {
    if (input is String) {
      return input;
    } else {
      return input?.toString() ?? defaultValue;
    }
  }

  static String? stringOrNull(dynamic input) {
    if (input is String) {
      return input;
    } else {
      return input?.toString();
    }
  }

  static Map<String, dynamic>? map(dynamic input) {
    if (input is Map<String, dynamic>) {
      return input;
    }
    return null;
  }

  /// Retrieve a nested field from [json] according to [keys], which
  /// specifies the nesting hierarchy as a sequence of keys separated by dots ('.').
  ///
  /// For example, the key 'a.b.c' will retrieve the value of 5 from the following map:
  /// {
  ///   a: {
  ///     b: { c: 5 },
  ///     c: 7
  ///   },
  ///   c: 8
  /// }
  static dynamic nested(Map<String, dynamic> json, String keys) {
    final splitKeys = keys.split('.');
    Map<String, dynamic> currentObject = json;
    for (int i = 0; i < splitKeys.length - 1; i++) {
      final key = splitKeys[i];

      final value = map(currentObject[key]);
      if (value != null) {
        currentObject = value;
      }
    }

    return currentObject[splitKeys.last];
  }

  /// Attempt to parse a list of T.
  static List<T> list<T>(dynamic input, [T Function(dynamic)? converter]) {
    if (input is List<T>) {
      if (converter != null) {
        return input.map((it) => converter(it)).toList();
      } else {
        return input;
      }
    }
    return [];
  }

  /// Attempt to parse a single object using [converter]
  static T? object<T>(dynamic input, JsonConverter<T> converter) {
    final parsed = map(input);
    return parsed != null ? converter(parsed) : null;
  }

  /// Attempt to parse a single object using [converter]
  static T objectFromMap<T>(Map<String, dynamic> input, JsonConverter<T> converter) {
    return converter(input);
  }

  /// Attempt to parse a list of objects using [itemConverter]. The list elements for
  /// which [itemConverter] returns null are not included in the result.
  static List<T> objectList<T>(dynamic input, JsonConverter<T> itemConverter) {
    final parsed = list(input);
    return parsed
        .map((it) {
          final itemMap = map(it);
          return itemMap != null ? itemConverter(itemMap) : null;
        })
        .whereType<T>()
        .toList();
  }

  /// Parse a duration from the number of seconds since the Epoch.
  static Duration? duration(dynamic input) {
    if (input is int) {
      return Duration(seconds: input);
    }
    return null;
  }
}
