import 'package:flutter_test/flutter_test.dart';
import 'package:appkit/common/util/serialize.dart';

void main() {
  test('Amounts should be serialized correctly', () {
    expect(Serialize.amount(607.425), '607.43');
    expect(Serialize.amount(607), '607.00');
    expect(Serialize.amount(35.855), '35.86');
    expect(Serialize.amount(73.315), '73.32');
    expect(Serialize.amount(1.005), '1.01');
    expect(Serialize.amount(859.385), '859.39');
    expect(Serialize.amount(0.045), '0.05');
    expect(Serialize.amount(89.684449), '89.68');
    expect(Serialize.amount(0.000000015), '0.00');
    expect(Serialize.amount(1.0), '1.00');
  });

  test('Quantities should be serialized correctly', () {
    expect(Serialize.quantity(607.4825), '607.483');
  });
}
