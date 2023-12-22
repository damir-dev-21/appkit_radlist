import 'package:flutter/cupertino.dart';

import 'initializable.controller.dart';
import 'initializable.screen.dart';

/// Combines the features of [InitializableScreenState] and [AutomaticKeepAliveClientMixin]
abstract class InitializableAutomaticKeepAliveScreenState<W extends StatefulWidget,
        C extends InitializableController> extends InitializableScreenState<W, C>
    with AutomaticKeepAliveClientMixin<W> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return doBuild(context);
  }
}
