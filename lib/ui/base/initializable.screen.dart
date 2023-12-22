import 'package:appkit/appkit.dart';
import 'package:flutter/material.dart';

import 'controller_provider.dart';
import 'initializable.controller.dart';

/// Class to be used for root screen widgets that need to asynchronously initialize
/// themselves, for example by requesting some initialization data from a backend API.
/// Works together with [InitializableController].
abstract class InitializableScreenState<W extends StatefulWidget, C extends InitializableController>
    extends State<W> {
  /// If true, then the content will be shown while the initialization logic is running
  /// the error screen will be shown if initialization logic fails.
  /// If false, then a loading spinner will be displayed while the initialization logic is running.
  final bool showContentImmediately;

  InitializableScreenState({
    this.showContentImmediately = false,
  });

  C? ctrl;

  /// Create the controller instance.
  C createController();

  /// Build an optional static wrapper widget, the screen's dynamic content
  /// is provided as [child].
  Widget? buildWrapper(Widget child) {
    return null;
  }

  /// Build the content of the screen that will be re-rendered on bloc change.
  Widget buildContent();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ctrl ??= createController();
    if (!ctrl!.hasError) {
      ctrl!.initialize();
    }
  }

  @override
  void dispose() {
    ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return doBuild(context);
  }

  @protected
  Widget doBuild(BuildContext context) {
    final widget = ControllerProvider<C>.value(
        value: ctrl!,
        builder: (context, ctrl) {
          final isLoading = ctrl.isLoading;
          final hasError = ctrl.hasError;

          return hasError
              ? Appkit.failedWidgetBuilder(onRetry: () {
                  ctrl.initialize(reload: true);
                })
              : showContentImmediately
                  ? buildContent()
                  : Appkit.loadingWidgetBuilder(
                      child: isLoading ? null : buildContent(),
                      isLoading: isLoading,
                    );
        });

    return buildWrapper(widget) ?? widget;
  }
}
