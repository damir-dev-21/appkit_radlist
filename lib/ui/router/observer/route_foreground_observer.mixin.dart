import 'package:appkit/framework/di_utils.dart';
import 'package:flutter/material.dart';

import 'app_route_observer.dart';

/// Updates the [isInForeground] variable when the current route enters or leaves
/// the foreground. This is different from using [mounted] because [isInForeground]
/// gets updated as soon as the route starts transitioning, but [mounted] changes
/// after the transition completes when the route is popped.
mixin RouteForegroundObserverMixin<T extends StatefulWidget> on State<T> implements AppRouteAware {
  AppRouteObserver? _routeObserver;
  bool isInForeground = false;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeObserver == null) {
      _routeObserver = provideOnce(context);
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

  /// Called when the current route begins entering the foreground.
  void onForegrounded() {}

  /// Called when the current route exists into background or is popped.
  void onBackgrounded() {}

  /// Called when the current route has been popped off.
  @override
  @mustCallSuper
  void didPop() {
    isInForeground = false;
    onBackgrounded();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  @mustCallSuper
  void didPopNext(Route<dynamic> next) {
    isInForeground = true;
    onForegrounded();
  }

  /// Called when the current route has been pushed.
  @override
  @mustCallSuper
  void didPush() {
    isInForeground = true;
    onForegrounded();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  @mustCallSuper
  void didPushNext(Route<dynamic> next) {
    isInForeground = false;
    onBackgrounded();
  }
}
