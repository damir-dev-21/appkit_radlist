import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base.controller.dart';

class ControllerProvider<T extends BaseController> extends ChangeNotifierProvider<T> {
  ControllerProvider({
    Key? key,
    required T Function() create,
    required Widget Function(BuildContext, T) builder,
  }) : super(
          key: key,
          create: (_) => create(),
          child: Consumer<T>(
            builder: (context, controller, _) => builder(context, controller),
          ),
        );

  ControllerProvider.value({
    Key? key,
    required T value,
    required Widget Function(BuildContext, T) builder,
  }) : super.value(
          key: key,
          value: value,
          child: Consumer<T>(
            builder: (context, controller, _) => builder(context, controller),
          ),
        );
}
