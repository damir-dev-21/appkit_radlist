// Copyright (c) 2013, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Modified for convenience.

import 'dart:math' as Math;

final _pattern = RegExp(r'^([+-]?\d*)(\.\d*)?([eE][+-]?\d+)?$');

final _d0 = Decimal.fromInt(0);
final _d1 = Decimal.fromInt(1);
final _d5 = Decimal.fromInt(5);
final _d10 = Decimal.fromInt(10);

final _i0 = BigInt.zero;
final _i1 = BigInt.one;
final _i2 = BigInt.two;
final _i5 = BigInt.from(5);
final _i10 = BigInt.from(10);
final _i31 = BigInt.from(31);

class Decimal implements Comparable<Decimal> {
  factory Decimal(BigInt numerator, [BigInt? denominator]) {
    denominator ??= _i1;
    if (denominator == _i0) throw ArgumentError();
    if (numerator == _i0) return Decimal._normalized(_i0, _i1);
    if (denominator < _i0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final aNumerator = numerator.abs();
    final aDenominator = denominator.abs();
    final gcd = aNumerator.gcd(aDenominator);
    return (gcd == _i1)
        ? Decimal._normalized(numerator, denominator)
        : Decimal._normalized(numerator ~/ gcd, denominator ~/ gcd);
  }

  factory Decimal.fromInt(int numerator, [int denominator = 1]) =>
      Decimal(BigInt.from(numerator), BigInt.from(denominator));

  static Decimal? tryParse(String decimalValue) {
    try {
      return Decimal.parse(decimalValue);
    } on FormatException catch (_) {
      return null;
    }
  }

  factory Decimal.parse(String decimalValue) {
    final match = _pattern.firstMatch(decimalValue);
    if (match == null) {
      throw FormatException('$decimalValue is not a valid format');
    }
    final group1 = match.group(1);
    final group2 = match.group(2);
    final group3 = match.group(3);

    var numerator = _i0;
    var denominator = _i1;
    if (group2 != null) {
      for (var i = 1; i < group2.length; i++) {
        denominator = denominator * _i10;
      }
      numerator = BigInt.parse('$group1${group2.substring(1)}');
    } else {
      if (group1 != null) numerator = BigInt.parse(group1);
    }
    if (group3 != null) {
      var exponent = BigInt.parse(group3.substring(1));
      while (exponent > _i0) {
        numerator = numerator * _i10;
        exponent -= _i1;
      }
      while (exponent < _i0) {
        denominator = denominator * _i10;
        exponent += _i1;
      }
    }
    return Decimal(numerator, denominator);
  }

  Decimal._normalized(this.numerator, this.denominator)
      : assert(denominator > _i0),
        assert(numerator.abs().gcd(denominator) == _i1);

  final BigInt numerator, denominator;

  static final zero = _d0;
  static final one = _d1;
  static final d100 = Decimal.fromInt(100);
  static final d9999 = Decimal.fromInt(9999);

  bool get isInteger => denominator == _i1;

  Decimal get inverse => Decimal(denominator, numerator);

  @override
  int get hashCode => (numerator + _i31 * denominator).hashCode;

  @override
  bool operator ==(Object other) =>
      other is Decimal && numerator == other.numerator && denominator == other.denominator;

  @override
  String toString() {
    if (numerator == _i0) return '0';
    if (isInteger) {
      return '$numerator';
    } else {
      return '$numerator/$denominator';
    }
  }

  String toDecimalString() {
    if (isInteger) return toStringAsFixed(0);

    final fractionDigits = hasFinitePrecision ? scale : 10;
    var asString = toStringAsFixed(fractionDigits);
    while (asString.contains('.') && (asString.endsWith('0') || asString.endsWith('.'))) {
      asString = asString.substring(0, asString.length - 1);
    }
    return asString;
  }

  // implementation of Comparable

  @override
  int compareTo(Decimal other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  // implementation of num

  Decimal operator +(Decimal other) => Decimal(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator);

  Decimal operator -(Decimal other) => Decimal(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator);

  Decimal operator *(Decimal other) =>
      Decimal(numerator * other.numerator, denominator * other.denominator);

  Decimal operator %(Decimal other) {
    final remainder = this.remainder(other);
    if (remainder == _d0) return _d0;
    return remainder + (isNegative ? other.abs() : _d0);
  }

  Decimal operator /(Decimal other) =>
      Decimal(numerator * other.denominator, denominator * other.numerator);

  /// Truncating division operator.
  ///
  /// The result of the truncating division [:a ~/ b:] is equivalent to
  /// [:(a / b).truncate():].
  Decimal operator ~/(Decimal other) => (this / other).truncate();

  Decimal operator -() => Decimal._normalized(-numerator, denominator);

  /// Return the remainder from dividing this [num] by [other].
  Decimal remainder(Decimal other) => this - (this ~/ other) * other;

  bool operator <(Decimal other) => compareTo(other) < 0;

  bool operator <=(Decimal other) => compareTo(other) <= 0;

  bool operator >(Decimal other) => compareTo(other) > 0;

  bool operator >=(Decimal other) => compareTo(other) >= 0;

  bool get isNaN => false;

  bool get isNegative => numerator < _i0;

  bool get isNonNegative => !isNegative;

  bool get isPositive => !isNegative && numerator != BigInt.zero;

  bool get isZero => numerator == _i0;

  bool get isInfinite => false;

  /// Returns the absolute value of this [num].
  Decimal abs() => isNegative ? (-this) : this;

  /// The signum function value of this [num].
  ///
  /// E.e. -1, 0 or 1 as the value of this [num] is negative, zero or positive.
  int get signum {
    final v = compareTo(_d0);
    if (v < 0) return -1;
    if (v > 0) return 1;
    return 0;
  }

  /// Returns the integer value closest to this [num].
  ///
  /// Rounds away from zero when there is no closest integer:
  /// [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  Decimal round() {
    final abs = this.abs();
    final absBy10 = abs * _d10;
    var r = abs.truncate();
    if (absBy10 % _d10 >= _d5) r += _d1;
    return isNegative ? -r : r;
  }

  /// Returns the greatest integer value no greater than this [num].
  Decimal floor() => isInteger
      ? truncate()
      : isNegative
          ? (truncate() - _d1)
          : truncate();

  /// Returns the least integer value that is no smaller than this [num].
  Decimal ceil() => isInteger
      ? truncate()
      : isNegative
          ? truncate()
          : (truncate() + _d1);

  /// Returns the integer value obtained by discarding any fractional digits
  /// from this [num].
  Decimal truncate() => Decimal._normalized(numerator ~/ denominator, _i1);

  /// Returns the integer value closest to `this`.
  ///
  /// Rounds away from zero when there is no closest integer:
  /// [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  ///
  /// The result is a double.
  double roundToDouble() => round().toDouble();

  /// Returns the greatest integer value no greater than `this`.
  ///
  /// The result is a double.
  double floorToDouble() => floor().toDouble();

  /// Returns the least integer value no smaller than `this`.
  ///
  /// The result is a double.
  double ceilToDouble() => ceil().toDouble();

  /// Returns the integer obtained by discarding any fractional digits from
  /// `this`.
  ///
  /// The result is a double.
  double truncateToDouble() => truncate().toDouble();

  /// Clamps the rational to be in the range [lowerLimit]-[upperLimit]. The
  /// comparison is done using [compareTo] and therefore takes [:-0.0:] into
  /// account.
  Decimal clamp(Decimal lowerLimit, Decimal upperLimit) => this < lowerLimit
      ? lowerLimit
      : this > upperLimit
          ? upperLimit
          : this;

  /// Truncates this [num] to an integer and returns the result as an [int].
  int toInt() => toBigInt().toInt();

  /// Truncates this [num] to a big integer and returns the result as an
  /// [BigInt].
  BigInt toBigInt() => numerator ~/ denominator;

  /// Return this [num] as a [double].
  ///
  /// If the number is not representable as a [double], an approximation is
  /// returned. For numerically large integers, the approximation may be
  /// infinite.
  double toDouble() => numerator / denominator;

  /// Inspect if this [num] has a finite precision.
  bool get hasFinitePrecision {
    // the denominator should only be a product of powers of 2 and 5
    var den = denominator;
    while (den % _i5 == _i0) {
      den = den ~/ _i5;
    }
    while (den % _i2 == _i0) {
      den = den ~/ _i2;
    }
    return den == _i1;
  }

  /// The precision of this [num].
  ///
  /// The sum of the number of digits before and after the decimal point.
  ///
  /// **WARNING for dart2js** : It can give bad result for large number.
  ///
  /// Throws [StateError] if the precision is infinite, i.e. when
  /// [hasFinitePrecision] is `false`.
  int get precision {
    if (!hasFinitePrecision) {
      throw StateError('This number has an infinite precision: $this');
    }
    var x = numerator;
    while (x % denominator != _i0) {
      x *= _i10;
    }
    x = x ~/ denominator;
    return x.abs().toString().length;
  }

  /// The scale of this [num].
  ///
  /// The number of digits after the decimal point.
  ///
  /// **WARNING for dart2js** : It can give bad result for large number.
  ///
  /// Throws [StateError] if the scale is infinite, i.e. when
  /// [hasFinitePrecision] is `false`.
  int get scale {
    if (!hasFinitePrecision) {
      throw StateError('This number has an infinite precision: $this');
    }
    var i = 0;
    var x = numerator;
    while (x % denominator != _i0) {
      i++;
      x *= _i10;
    }
    return i;
  }

  /// Converts a [num] to a string representation with [fractionDigits] digits
  /// after the decimal point.
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits == 0) {
      return round().toBigInt().toString();
    } else {
      var mul = _i1;
      for (var i = 0; i < fractionDigits; i++) {
        mul *= _i10;
      }
      final mulRat = Decimal(mul);
      final lessThanOne = abs() < _d1;
      final tmp = (lessThanOne ? (abs() + _d1) : abs()) * mulRat;
      final tmpRound = tmp.round();
      final intPart =
          (lessThanOne ? ((tmpRound ~/ mulRat) - _d1) : (tmpRound ~/ mulRat)).toBigInt();
      final decimalPart = tmpRound.toBigInt().toString().substring(intPart.toString().length);
      return '${isNegative ? '-' : ''}$intPart.$decimalPart';
    }
  }

  /// Converts a [num] to a string in decimal exponential notation with
  /// [fractionDigits] digits after the decimal point.
  String toStringAsExponential([int? fractionDigits]) =>
      toDouble().toStringAsExponential(fractionDigits);

  /// Converts a [num] to a string representation with [precision] significant
  /// digits.
  String toStringAsPrecision(int precision) {
    assert(precision > 0);

    if (this == _d0) {
      return precision == 1 ? '0' : '0.'.padRight(1 + precision, '0');
    }

    var limit = _d1;
    for (var i = 0; i < precision; i++) {
      limit *= _d10;
    }

    var shift = _d1;
    var pad = 0;
    while (abs() * shift < limit) {
      pad++;
      shift *= _d10;
    }
    while (abs() * shift >= limit) {
      pad--;
      shift /= _d10;
    }
    final value = (this * shift).round() / shift;
    return pad <= 0 ? value.toString() : value.toStringAsFixed(pad);
  }

  /// Returns `this` to the power of [exponent].
  ///
  /// Returns [one] if the [exponent] equals `0`.
  ///
  /// The [exponent] must otherwise be positive.
  Decimal pow(int exponent) => Decimal(numerator.pow(exponent), denominator.pow(exponent));

  final _precisionFactors = <int, Decimal>{};

  /// Round this Decimal to the given precision.
  Decimal toPrecision(int precision) {
    Decimal factor =
        _precisionFactors[precision] ?? Decimal.fromInt(Math.pow(10, precision).toInt());
    _precisionFactors[precision] = factor;
    return (this * factor).round() / factor;
  }

  double toPrecisionAsDouble(int precision) => toPrecision(precision).toDouble();

  Decimal max(Decimal other) => this > other ? this : other;

  Decimal min(Decimal other) => this > other ? other : this;
}
