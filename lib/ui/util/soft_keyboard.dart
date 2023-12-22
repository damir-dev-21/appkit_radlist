import 'package:appkit/ui/router/app_router.dart';
import 'package:flutter/material.dart';

abstract class SoftKeyboard {
  /// Close the soft keyboard. If [context] is passed, then it is used
  /// to determine the currently focused FocusScope, which is not always possible
  /// to determine from the global context.
  static void close([BuildContext? context]) {
    final currentContext = context ?? AppRouter.navigatorKey.currentContext!;
    final focusScope = FocusScope.of(currentContext);
    focusScope.unfocus();
  }
}
