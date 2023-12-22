import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/common/types/decimal.dart';
import 'package:intl/intl.dart';

abstract class Serialize {
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  static String amount(double amount) {
    return amount.toPrecision(2).toStringAsFixed(2);
  }

  static String amountDecimal(Decimal amount) {
    return Serialize.amount(amount.toDouble());
  }

  static String quantity(double quantity) {
    return quantity.toPrecision(3).toStringAsFixed(3);
  }

  static String quantityDecimal(Decimal quantity) {
    return Serialize.quantity(quantity.toDouble());
  }

  static String date(DateTime date) => _dateFormat.format(date);

  static String dateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

  static String? value(dynamic value) {
    if (value is double) {
      return amount(value);
    } else if (value is DateTime) {
      return dateTime(value);
    } else if (value is bool) {
      return value ? '1' : '0';
    } else {
      return value?.toString();
    }
  }
}
