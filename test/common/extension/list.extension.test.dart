import 'package:appkit/common/extension/list.extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('List getOrNull function test', () {
    final List<String> list = ['one', 'two', 'three'];
    final firstItem = list.getOrNull(0);
    final fourItem = list.getOrNull(4);
    expect(firstItem, 'one');
    expect(fourItem, null);
  });
  test('List mapIndexed function test', () {
    final List<String> list = ['one', 'two', 'three'];
    final mapIndexed = list.mapIndexed((item, index) => item.length > 3).toList();
    expect(mapIndexed, [false, false, true]);
    final emptyList =
        list.mapIndexed((item, index) => true).where((element) => element is double).toList();
    expect(emptyList, []);
    final indexToItem = list.mapIndexed((item, index) => '$index: $item').toList();
    expect(indexToItem, ['0: one', '1: two', '2: three']);
  });
  test('List maxBy function test', () {
    final List<String> list = ['one', 'two', 'three'];
    String? maxBy = list.maxBy((item) => item.length);
    expect(maxBy, list[2]);
    list.add('eleven');
    maxBy = list.maxBy((item) => item.length);
    expect(maxBy, list[3]);
  });
  test('List associateBy function test', () {
    final List<String> list = ['one', 'two', 'three'];
    final map = list.associateBy((item) => list.indexOf(item));
    expect(map, {0: 'one', 1: 'two', 2: 'three'});
  });
}
