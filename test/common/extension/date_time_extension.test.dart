import 'package:appkit/common/extension/date_time.extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DateTime isOnSameDay function test', () {
    DateTime date = DateTime(2022, 5, 26);
    DateTime sameDate = DateTime(2022, 5, 26);
    DateTime otherDay = DateTime(2022, 6, 27);
    bool isOnSameDay = date.isOnSameDay(sameDate);
    expect(isOnSameDay, true);
    isOnSameDay = date.isOnSameDay(otherDay);
    expect(isOnSameDay, false);
  });
  test('DateTime atEndOfDay function test', () {
    DateTime date = DateTime(2022, 5, 26);
    final atEndOfDay = date.atEndOfDay;
    expect(atEndOfDay, DateTime(2022, 5, 26, 23, 59, 59, 999, 999));
  });
}
