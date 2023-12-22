import 'package:appkit/ui/router/navigator.extension.dart';
import 'package:flutter/material.dart';

abstract class AppRouteAware {
  /// Called when the top route has been popped off, and the current route
  /// shows up.
  void didPopNext(Route<dynamic> next) {}

  /// Called when the current route has been pushed.
  void didPush() {}

  /// Called when the current route has been popped off.
  void didPop() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  void didPushNext(Route<dynamic> next) {}
}

class AppRouteObserver<R extends Route<dynamic>> extends NavigatorObserver {
  final bool isRootObserver;

  final Map<R, Set<AppRouteAware>> _listeners = <R, Set<AppRouteAware>>{};
  final _observers = <GlobalKey<NavigatorState>, AppRouteObserver>{};

  AppRouteObserver({this.isRootObserver = false});

  /// Subscribe [routeAware] to be informed about changes to [route].
  ///
  /// Going forward, [routeAware] will be informed about qualifying changes
  /// to [route], e.g. when [route] is covered by another route or when [route]
  /// is popped off the [Navigator] stack.
  void subscribe(AppRouteAware routeAware, R route) {
    final Set<AppRouteAware> subscribers = _listeners.putIfAbsent(route, () => <AppRouteAware>{});
    if (subscribers.add(routeAware)) {
      routeAware.didPush();
    }
  }

  /// Unsubscribe [routeAware].
  ///
  /// [routeAware] is no longer informed about changes to its route. If the given argument was
  /// subscribed to multiple types, this will unregister it (once) from each type.
  void unsubscribe(AppRouteAware routeAware) {
    for (final R route in _listeners.keys) {
      final Set<AppRouteAware>? subscribers = _listeners[route];
      subscribers?.remove(routeAware);
    }
  }

  /// Bind a nested route [observer] to this observer. The [navigatorKey] specifies
  /// the key that should be attached to the Navigator to which the [observer] belongs.
  void subscribeNestedObserver(GlobalKey<NavigatorState> navigatorKey, AppRouteObserver observer) {
    _observers.putIfAbsent(navigatorKey, () => observer);
  }

  /// Unsubscribe the nested route observer that was previously subscribed using [navigatorKey].
  void unsubscribeNestedObserver(GlobalKey<NavigatorState> navigatorKey) {
    _observers.remove(navigatorKey);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is R && previousRoute is R) {
      final List<AppRouteAware>? previousSubscribers = _listeners[previousRoute]?.toList();

      if (previousSubscribers != null) {
        for (final AppRouteAware routeAware in previousSubscribers) {
          routeAware.didPopNext(route);
        }
      }

      final List<AppRouteAware>? subscribers = _listeners[route]?.toList();

      if (subscribers != null) {
        for (final AppRouteAware routeAware in subscribers) {
          routeAware.didPop();
        }
      }

      _observers.forEach((navigatorKey, observer) {
        final nestedPreviousRoute = navigatorKey.currentState?.currentRoute;
        if (nestedPreviousRoute != null) {
          observer.didPop(route, nestedPreviousRoute);
        }
      });
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is R && previousRoute is R) {
      final Set<AppRouteAware>? previousSubscribers = _listeners[previousRoute];

      if (previousSubscribers != null) {
        for (final AppRouteAware routeAware in previousSubscribers) {
          routeAware.didPushNext(route);
        }
      }
    }

    _observers.forEach((navigatorKey, observer) {
      final nestedPreviousRoute = navigatorKey.currentState?.currentRoute;
      if (nestedPreviousRoute != null) {
        observer.didPush(route, nestedPreviousRoute);
      }
    });
  }
}
