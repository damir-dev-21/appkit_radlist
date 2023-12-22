import 'package:appkit/ui/responsive/model/device_screen_type.dart';
import 'package:appkit/ui/util/error_display.dart';
import 'package:appkit/ui/util/executor.dart';
import 'package:flutter/material.dart';

typedef Widget LoadingWidgetBuilder({Widget? child, required bool isLoading});

typedef Widget FailedWidgetBuilder({required VoidCallback onRetry});

typedef EmptyWidgetBuilder = Widget Function();

typedef PreferredScreenTypeGetter = EDeviceScreenType Function(BuildContext);

abstract class Appkit {
  static bool get isConfigured => _isConfigured;
  static bool _isConfigured = false;

  static LoadingWidgetBuilder get loadingWidgetBuilder => _loadingWidgetBuilder;
  static late LoadingWidgetBuilder _loadingWidgetBuilder;

  static FailedWidgetBuilder get failedWidgetBuilder => _failedWidgetBuilder;
  static late FailedWidgetBuilder _failedWidgetBuilder;

  static EmptyWidgetBuilder get emptyWidgetBuilder => _emptyWidgetBuilder;
  static late EmptyWidgetBuilder _emptyWidgetBuilder;

  static PreferredScreenTypeGetter? get preferredScreenTypeGetter => _preferredScreenTypeGetter;
  static PreferredScreenTypeGetter? _preferredScreenTypeGetter;

  /// Configure the library.
  /// [errorDisplay] is used to display errors to the user.
  /// [loadingWidgetBuilder] is used to build a widget to display a loading state.
  /// [failedWidgetBuilder] is used to build a widget to display a failed state with an ability
  ///   to retry an operation.
  /// [emptyWidgetBuilder] is used to build a widget to display an empty state.
  /// [preferredScreenTypeGetter] is used to override the breakpoint logic of screen type deciders
  static void configure({
    required ErrorDisplay errorDisplay,
    required LoadingWidgetBuilder loadingWidgetBuilder,
    required FailedWidgetBuilder failedWidgetBuilder,
    required EmptyWidgetBuilder emptyWidgetBuilder,
    PreferredScreenTypeGetter? preferredScreenTypeGetter,
  }) {
    Executor.setErrorDisplay(errorDisplay);
    _loadingWidgetBuilder = loadingWidgetBuilder;
    _failedWidgetBuilder = failedWidgetBuilder;
    _emptyWidgetBuilder = emptyWidgetBuilder;
    _preferredScreenTypeGetter = preferredScreenTypeGetter;

    _isConfigured = true;
  }
}
