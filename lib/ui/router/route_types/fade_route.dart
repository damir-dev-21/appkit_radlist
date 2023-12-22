import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Fades in the new screen
class FadeRoute<T> extends PageRouteBuilder<T> {
  static const DURATION = Duration(milliseconds: 300);

  FadeRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, _, __) => builder(context),
          barrierDismissible: true,
          transitionDuration: DURATION,
          reverseTransitionDuration: DURATION,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation),
            child: child,
          ),
          settings: settings,
          opaque: false,
        );
}
