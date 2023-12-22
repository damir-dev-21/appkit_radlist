import 'package:flutter/material.dart';

extension NavigatorExtension on NavigatorState {
  /// Return the current route's name, or null if it is anonymous.
  String? getCurrentRouteName() {
    String? result;
    popUntil((route) {
      result = route.settings.name;
      // We return true immediately to avoid popping anything. A hacky way, but works.
      return true;
    });
    return result;
  }

  bool? isCurrentRouteFirst() {
    bool? result;
    popUntil((route) {
      result = route.isFirst;
      return true;
    });
    return result;
  }

  Route? get currentRoute {
    Route? result;
    popUntil((route) {
      result = route;
      return true;
    });
    return result;
  }
}
