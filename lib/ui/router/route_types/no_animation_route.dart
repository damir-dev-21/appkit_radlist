import 'package:flutter/material.dart';

/// Route without any animations and effects.
class NoAnimationRoute<T> extends PageRouteBuilder<T> {
  NoAnimationRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, _, __) => builder(context),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
          opaque: true,
        );
}
