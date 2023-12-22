import 'package:appkit/framework/di_utils.dart';
import 'package:flutter/material.dart';

import 'app_tab_route_observer.dart';

/// Used to be notified when the current tab gets selected/deselected.
mixin TabObserverMixin<T extends StatefulWidget> on State<T> implements TabObserver {
  AppTabRouteObserver? _routeObserver;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _routeObserver = provideOnceOrNull(context);
      _routeObserver?.addTabObserver(this);
    }
  }

  @override
  void dispose() {
    _routeObserver?.removeTabObserver(this);
    super.dispose();
  }

  @override
  void onTabSelected() {}

  @override
  void onTabDeselected() {}
}
