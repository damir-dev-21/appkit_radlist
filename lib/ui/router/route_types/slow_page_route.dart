import 'package:flutter/material.dart';

/// A MaterialPageRoute with slow animations for debugging.
class SlowPageRoute extends MaterialPageRoute {
  SlowPageRoute({RouteSettings? settings, required WidgetBuilder builder})
      : super(settings: settings, builder: builder);

  @override
  Duration get transitionDuration => Duration(seconds: 2);
}
