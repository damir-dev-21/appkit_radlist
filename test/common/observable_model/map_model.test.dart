import 'package:appkit/common/observable_model/map_model.dart';
import 'package:appkit/ui/base/base.controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MapModel functions test', () {
    final controller = BaseController();
    final List<String> list = ['one', 'two', 'three'];
    final mapModel = MapModel<int, String>(controller: controller);
    mapModel[0] = 'one';
    mapModel[1] = 'two';
    mapModel[2] = 'three';
    expect(mapModel[0], 'one');
    expect(mapModel.values.toList(), list);
    int length = 0;
    mapModel.addListener((previousLength) {
      length = mapModel.length;
    });
    mapModel.remove(0);
    expect(mapModel.length, length);
    expect(mapModel.values.toList(), ['two', 'three']);
    expect(mapModel.isEmpty, false);
    expect(mapModel.length, 2);
    mapModel.removeAllListeners();
    mapModel.clear();
    expect(mapModel.length, 0);
  });
}
