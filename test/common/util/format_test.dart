import 'package:appkit/common/constants/unicode_symbols.dart';
import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/common/util/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final _nbsp = UnicodeSymbols.NBSP;

  test('Format.amount', () {
    expect(Format.amount(732.685, includeKztSymbol: false), '732.69');
    expect(Format.amountDecimal(732.685.toDecimal(), includeKztSymbol: false), '732.69');
    expect(Format.amount(1000.56, includeKztSymbol: false), '1000.56');
    expect(Format.amountDecimal(1000.56.toDecimal(), includeKztSymbol: false), '1000.56');
    expect(Format.amount(12345.965, includeKztSymbol: false), '12${_nbsp}345.97');
    expect(
        Format.amountDecimal(12345.965.toDecimal(), includeKztSymbol: false), '12${_nbsp}345.97');
    expect(Format.amount(-1937454.865, includeKztSymbol: false), '-1${_nbsp}937${_nbsp}454.87');
    expect(Format.amountDecimal(-1937454.865.toDecimal(), includeKztSymbol: false),
        '-1${_nbsp}937${_nbsp}454.87');
  });
}
