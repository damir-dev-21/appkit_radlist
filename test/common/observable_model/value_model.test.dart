import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/base/base.controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ValueModel functions test', () {
    final controller = BaseController();
    TestWidgetsFlutterBinding.ensureInitialized();
    ValueModel<String> model = ValueModel<String>(controller: controller, initialVal: 'one');
    expect(model.val, 'one');
    // check listener
    String? str;
    model.addListener((val) {
      str = val;
    });
    model.val = 'two';
    expect(str, 'two');
  });
}
