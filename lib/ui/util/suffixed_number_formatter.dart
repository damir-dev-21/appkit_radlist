import 'package:appkit/common/constants/unicode_symbols.dart';
import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/common/types/decimal.dart';
import 'package:appkit/common/util/format.dart';
import 'package:appkit/common/util/parse.dart';
import 'package:flutter/services.dart';

/// Formats the input as a number (with thousands separators) and with a given
/// suffix string. Usually used to format monetary input fields, with a currency symbol
/// as the suffix.
class SuffixedNumberFormatter extends TextInputFormatter {
  final String? suffix;
  final int fractionLength;
  final int? maxLength;
  final bool allowNegative;

  late final int _suffixLength;

  static const _nbsp = UnicodeSymbols.NBSP;

  /// Digits, spaces and a radix point at the start of the input string.
  static final _startNumberPattern = RegExp(r'^[\d ' + _nbsp + r'.,]+');

  /// The group captures digits, spaces and a radix point after the first
  /// non-digit, non-space, non-radix point character. This is used to collect characters
  /// that the user enters after the [suffix], so that we can place them before it.
  static final _endNumberPattern = RegExp(r'[^\d ' + _nbsp + r'.,]+([\d ' + _nbsp + r'.,]+)$');

  /// Same patterns as above, but these also allow a negation operator '-' to be entered.
  static final _startNegativeNumberPattern = RegExp(r'^-?[\d ' + _nbsp + r'.,]+');
  static final _endNegativeNumberPattern =
      RegExp(r'[^\-\d ' + _nbsp + r'.,]+([\-\d ' + _nbsp + r'.,]+)$');

  SuffixedNumberFormatter({
    this.suffix,
    this.fractionLength = 2,
    this.maxLength,
    this.allowNegative = false,
  }) : _suffixLength = suffix != null ? suffix.length + 1 : 0;

  factory SuffixedNumberFormatter.moneyFormatter() {
    return SuffixedNumberFormatter(
      suffix: UnicodeSymbols.KZT,
      fractionLength: 2,
      maxLength: 16,
    );
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (allowNegative && newValue.text.contains('-', 1)) {
      final oldNumber = parseNegativeNumber(oldValue.text);
      if (oldNumber == 0) {
        return oldValue;
      }

      final newNumber = oldNumber != null ? -oldNumber : 0.0;
      // Shift offset left or right depending on whether a negation symbol was prepended or not.
      final offset = oldValue.selection.baseOffset + (newNumber < 0 ? 1 : -1);

      return TextEditingValue(
        text: _appendSuffix(Format.number(newNumber, fractionLength: fractionLength)),
        selection: TextSelection.collapsed(
          offset: offset,
        ),
      );
    }

    final startPattern = allowNegative ? _startNegativeNumberPattern : _startNumberPattern;
    final endPattern = allowNegative ? _endNegativeNumberPattern : _endNumberPattern;

    final startMatch = startPattern.firstMatch(newValue.text);
    final endMatch = endPattern.firstMatch(newValue.text);

    if (startMatch != null || endMatch != null) {
      String startNumber = '', endNumber = '';
      if (startMatch != null) {
        startNumber = newValue.text.substring(startMatch.start, startMatch.end);
      }
      if (endMatch != null) {
        endNumber = endMatch.group(1) ?? '';
      }

      String? formattedNumber = Format.numericInput(
        '$startNumber$endNumber'.trim(),
        fractionLength: fractionLength,
        stripTrailingZeros: false,
      );
      final maxLength = this.maxLength;
      if (formattedNumber != null && maxLength != null && formattedNumber.length > maxLength) {
        formattedNumber = Format.number(parseNumber(oldValue.text));
      }

      TextSelection selection;
      if (formattedNumber == null) {
        // Put cursor after the '0'
        selection = TextSelection.collapsed(offset: 1);
      } else {
        final lengthDiff = formattedNumber.length + _suffixLength - newValue.text.length;
        if (newValue.selection.baseOffset > formattedNumber.length) {
          selection = TextSelection.collapsed(offset: formattedNumber.length);
        } else {
          if (lengthDiff == 1 && formattedNumber[newValue.selection.baseOffset] == ' ') {
            // Deleting a space character in the middle
            selection = newValue.selection;
          } else if (lengthDiff > 0) {
            if (oldValue.text.isEmpty) {
              // Previous value was empty, so we initialize the cursor at the end
              // of the formatted number.
              selection = TextSelection.collapsed(offset: formattedNumber.length);
            } else {
              // Space was inserted by formatter
              selection =
                  TextSelection.collapsed(offset: newValue.selection.baseOffset + lengthDiff);
            }
          } else if (lengthDiff < 0 && newValue.selection.baseOffset > 1) {
            // Character was deleted that resulted in a space being removed after formatting
            // We move the cursor before the space unless the removed space was the very first one.
            selection = TextSelection.collapsed(offset: newValue.selection.baseOffset - 1);
          } else {
            selection = newValue.selection;
          }
        }
      }

      return TextEditingValue(
        text: _appendSuffix(formattedNumber ?? '0'),
        selection: selection,
      );
    } else {
      return TextEditingValue(
        text: _appendSuffix('0'),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  String _appendSuffix(String text) {
    return '$text$_nbsp$suffix';
  }

  String? formatValue(double value, [TextEditingValue? oldValue]) {
    final stringValue = Format.number(
      value,
      fractionLength: fractionLength,
      stripTrailingZeros: true,
    );
    if (oldValue != null) {
      return formatEditUpdate(
        oldValue,
        TextEditingValue(
          text: stringValue,
          selection: TextSelection.collapsed(offset: stringValue.length),
        ),
      ).text;
    } else
      return null;
  }

  static double? parseNumber(String input) {
    return _parseNumber(input, _startNumberPattern);
  }

  static Decimal? parseDecimal(String input) {
    return parseNumber(input)?.toDecimal();
  }

  static double? parseNegativeNumber(String input) {
    return _parseNumber(input, _startNegativeNumberPattern);
  }

  static Decimal? parseNegativeDecimal(String input) {
    return parseNegativeNumber(input)?.toDecimal();
  }

  static double? _parseNumber(String? input, RegExp pattern) {
    if (input == null) {
      return null;
    }

    final numberMatch = pattern.firstMatch(input);
    if (numberMatch != null) {
      final numberString = input.substring(numberMatch.start, numberMatch.end);
      return Parse.amount(numberString);
    }

    return null;
  }
}
