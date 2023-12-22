import 'package:appkit/ui/widget/app_scaffold.widget.dart';
import 'package:flutter/material.dart';

class UndefinedRoute extends MaterialPageRoute {
  UndefinedRoute(RouteSettings settings)
      : super(
          settings: settings,
          builder: (context) => AppScaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
}
