import 'package:appkit/common/types/decimal.dart';

extension NumberExtension on num {
  /// Round this number to the given precision. [precision] is the number
  /// of significant digits after the radix point.
  double toPrecision(int precision) {
    return Decimal.parse(toString()).toPrecision(precision).toDouble();
  }

  Decimal toDecimal([int? precision]) {
    if (precision != null) {
      return Decimal.parse(toPrecision(precision).toString());
    } else {
      return Decimal.parse(toString());
    }
  }

  /// Map this number in interval (inputStart, inputEnd) to interval (outputStart, outputEnd)
  double mapInterval(num inputStart, num inputEnd, num outputStart, num outputEnd) {
    return (this - inputStart) * (outputEnd - outputStart) / (inputEnd - inputStart) + outputStart;
  }

  /// Clamp this value at the specified maximum.
  T coerceAtMost<T extends num>(T max) => this > max ? max : this as T;

  /// Clamp this value at the specified minimum.
  T coerceAtLeast<T extends num>(T min) => this < min ? min : this as T;
}
