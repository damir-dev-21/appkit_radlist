import 'package:appkit/ui/router/navigator.extension.dart';
import 'package:flutter/cupertino.dart';
import 'route_types/fade_route.dart';
import 'route_types/no_animation_route.dart';

class AppRouter {
  static const Type DEFAULT_ROUTE_TYPE = CupertinoPageRoute;
  static const Duration DEFAULT_TRANSITION_DURATION =
      Duration(microseconds: 400);

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get currentContext => navigatorKey.currentContext!;

  AppRouter._();

  /// Return the current route's name, or null if it is anonymous.
  static String? getCurrentRouteName() {
    String? currentRouteName;
    navigatorKey.currentState?.popUntil((route) {
      currentRouteName = route.settings.name;
      return true;
    });
    return currentRouteName;
  }

  /// Return the current route, if any.
  static Route<dynamic>? getCurrentRoute() {
    return navigatorKey.currentState?.currentRoute;
  }

  /// Push a new route. If [context] is provided, then the nearest Navigator is used,
  /// otherwise the root Navigator is used.
  static Future<T?> push<T>(Route<T> route, {BuildContext? context}) {
    if (context != null) {
      return Navigator.push(context, route);
    } else {
      return navigatorKey.currentState?.push<T>(route) ?? Future(() => null);
    }
  }

  /// Push a new screen. If [context] is provided, then the nearest Navigator is used,
  /// otherwise the root Navigator is used.
  static Future<T?> pushScreen<T>(
    WidgetBuilder builder, {
    String? routeName,
    BuildContext? context,
  }) {
    final settings = routeName != null ? RouteSettings(name: routeName) : null;
    if (context != null) {
      return Navigator.push(context, route(builder, settings: settings));
    } else {
      return push<T>(route(builder, settings: settings));
    }
  }

  static Future<T?>? replace<T>(Route<T> route) {
    return navigatorKey.currentState?.pushReplacement(route);
  }

  static Future<T?>? replaceScreen<T, TO extends Object>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    TO? result,
  }) {
    return navigatorKey.currentState?.pushReplacement(
      route(builder, settings: settings),
      result: result,
    );
  }

  static Future<T?>? pushNamed<T>(
    String routeName, {
    dynamic params,
  }) {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: params);
  }

  static Future<void>? pushReplacementNamed(
    String routeName, {
    dynamic params,
    dynamic result,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: params,
      result: result,
    );
  }

  static Future<void>? pushAndRemoveUntil(
      Route<dynamic> newRoute, bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState?.pushAndRemoveUntil(newRoute, predicate);
  }

  static Future<void>? replaceRoot(String routeName) {
    return navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (_) => false);
  }

  static void pop([dynamic result]) {
    navigatorKey.currentState?.pop(result);
  }

  static void popUntil(bool Function(Route<dynamic> route) predicate,
      {BuildContext? context}) {
    if (context != null) {
      Navigator.popUntil(context, predicate);
    } else {
      navigatorKey.currentState?.popUntil(predicate);
    }
  }

  /// Pop the global navigator (or the navigator closest to [context] if provided)
  /// until the very first route in the stack.
  static void popToRoot([BuildContext? context]) {
    popUntil((route) => route.isFirst, context: context);
  }
}

Route<T> route<T>(
  WidgetBuilder builder, {
  bool fullscreenDialog = false,
  RouteSettings? settings,
}) {
  return CupertinoPageRoute(
    builder: builder,
    fullscreenDialog: fullscreenDialog,
    settings: settings,
  );
}

Route<T> fadeRoute<T>(
  WidgetBuilder builder, {
  RouteSettings? settings,
}) {
  return FadeRoute(
    builder: builder,
    settings: settings,
  );
}

Route<T> noAnimationRoute<T>(
  WidgetBuilder builder, {
  RouteSettings? settings,
}) {
  return NoAnimationRoute(
    builder: builder,
    settings: settings,
  );
}
