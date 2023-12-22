import 'package:flutter_test/flutter_test.dart';
import 'package:appkit/common/extension/number.extensions.dart';

void main() {
  test('Should correctly round floating point numbers', () {
    expect(607.425.toPrecision(2), 607.43);
    expect(35.855.toPrecision(2), 35.86);
    expect(73.315.toPrecision(2), 73.32);
    expect(1.005.toPrecision(2), 1.01);
    expect(859.385.toPrecision(2), 859.39);
    expect(0.045.toPrecision(2), 0.05);
    expect(89.684449.toPrecision(2), 89.68);
    expect(0.000000015.toPrecision(8), 0.00000002);
    expect(1.0.toPrecision(2), 1.0);
  });
}
