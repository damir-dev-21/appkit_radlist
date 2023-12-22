import 'package:appkit/framework/di_utils.dart';
import 'package:appkit/ui/router/observer/nested_route_observer.dart';
import 'package:flutter/material.dart';

import 'app_route_observer.dart';
import 'app_tab_route_observer.dart';

/// Used by stateful widgets to observe route changes.
mixin RouteObserverMixin<T extends StatefulWidget> on State<T> implements AppRouteAware {
  AppRouteObserver? _routeObserver;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeObserver == null) {
      // We first attempt to retrieve NestedRouteObserver, then the AppTabRouteObserver,
      // which is supposed to be nested under the global AppRouteObserver. If that fails
      // we retrieve the global AppRouteObserver.
      _routeObserver = provideOnceOrNull<NestedRouteObserver>(context) ??
          provideOnceOrNull<AppTabRouteObserver>(context) ??
          provideOnce(context);
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null) _routeObserver?.subscribe(this, modalRoute);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {}

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext(Route<dynamic> next) {}

  /// Called when the current route has been pushed.
  @override
  void didPush() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext(Route<dynamic> next) {}
}
