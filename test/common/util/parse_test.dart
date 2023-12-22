import 'package:flutter_test/flutter_test.dart';
import 'package:appkit/common/types/decimal.dart';
import 'package:appkit/common/util/parse.dart';

void main() {
  test('Parse.decimal', () {
    expect(Parse.decimal('732.835'), Decimal.parse('732.835'));
    expect(Parse.decimal(732), Decimal.fromInt(732));
    expect(Parse.decimal(732.835), Decimal.parse('732.835'));
  });
}
