import 'package:appkit/common/observable_model/list_model.dart';
import 'package:appkit/ui/base/base.controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ListModel functions test', () {
    final controller = BaseController();
    final List<String> list = ['one', 'two', 'three'];
    final listModel = ListModel<String>(controller: controller, initialList: list);
    final getList = listModel.list;
    expect(getList, list);
    expect(listModel.isEmpty, false);
    expect(listModel.lastOrNull, list.last);
    expect(listModel.length, 3);
    listModel.add('four');
    expect(listModel.lastOrNull, 'four');
    listModel.addAll(['fivem', 'six']);
    expect(listModel.lastOrNull, 'six');
    expect(listModel.length, 6);
    bool isRemoved = listModel.remove('six');
    expect(isRemoved, true);
    isRemoved = listModel.remove('six');
    expect(isRemoved, false);
    expect(listModel.length, 5);
    String checker = '';
    listModel.addListener((item) {
      checker = item.last;
    });
    String seven = 'seven';
    listModel.add(seven);
    expect(seven, checker);
    listModel.removeAllListener();
    listModel.clear();
    expect([], listModel.list);
  });
}
