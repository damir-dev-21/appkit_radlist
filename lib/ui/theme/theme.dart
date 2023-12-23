import 'package:appkit/data/storage/local_storage.dart';
import 'package:appkit/framework/di_utils.dart';
import 'package:flutter/material.dart';

import 'custom_theme_data.dart';
import 'theme_provider.dart';

CustomThemeData theme(BuildContext context) {
  return context.dependOnInheritedWidgetOfExactType<_CustomThemeInheritedWidget>()!.customThemeData;
}

_CustomThemeWrapperState themeState(BuildContext context) {
  return context
      .dependOnInheritedWidgetOfExactType<_CustomThemeInheritedWidget>()!
      .themeWrapperState;
}

class CustomThemeWrapper extends StatefulWidget {
  final WidgetBuilder builder;
  final ThemeProvider themeProvider;

  CustomThemeWrapper({
    Key? key,
    required this.builder,
    required this.themeProvider,
  }) : super(key: key);

  @override
  _CustomThemeWrapperState createState() => _CustomThemeWrapperState();
}

class _CustomThemeWrapperState extends State<CustomThemeWrapper> {
  ThemeMode _mode = ThemeMode.light;
  static const _LS_KEY_THEME_KEY = 'kz.appkit.themeKey';

  @override
  Widget build(BuildContext context) {
    Brightness brightness;

    final LocalStorage localStorage = provideOnce(context);

    /// where 1 is light and 2 is dark
    final themeId = localStorage.getInt(_LS_KEY_THEME_KEY);
    if (themeId != 0) {
      brightness = themeId == 1 ? Brightness.light : Brightness.dark;
      _mode = brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
    } else if (_mode == ThemeMode.system) {
      brightness = MediaQuery.of(context).platformBrightness;
    } else if (_mode == ThemeMode.dark) {
      brightness = Brightness.dark;
    } else {
      brightness = Brightness.light;
    }

    return _CustomThemeInheritedWidget(
      customThemeData: widget.themeProvider.getTheme(brightness),
      child: Builder(
        builder: widget.builder,
      ),
      themeWrapperState: this,
    );
  }

  void setMode(ThemeMode mode) {
    final LocalStorage localStorage = provideOnce(context);
    final indexMode = mode == ThemeMode.light ? 1 : 2;
    localStorage.putInt(_LS_KEY_THEME_KEY, indexMode);
    setState(() {
      _mode = mode;
    });
  }

  bool get isLightMode => _mode == ThemeMode.light;
}

class _CustomThemeInheritedWidget extends InheritedWidget {
  final CustomThemeData customThemeData;
  final _CustomThemeWrapperState themeWrapperState;

  _CustomThemeInheritedWidget({
    Key? key,
    required Widget child,
    required this.customThemeData,
    required this.themeWrapperState,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CustomThemeInheritedWidget oldWidget) {
    return oldWidget.customThemeData.mode != customThemeData.mode;
  }
}
