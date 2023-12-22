import 'dart:io';

import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

import 'misc/ios_keyboard_dismiss_wrapper.widget.dart';

/// Same as Scaffold, but adds SafeArea below to handle iPhone X-style bottom strip.
class AppScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Color? safeAreaColor;
  final bool extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;

  AppScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.safeAreaColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
  }) : super(key: key);

  static AppScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType();
  }

  @override
  AppScaffoldState createState() => AppScaffoldState();
}

class AppScaffoldState extends State<AppScaffold> {
  bool _isIosKeyboardDismissOverlayVisible = false;

  /// Function called by [IosKeyboardDismissWrapper] when the keyboard dismiss
  /// overlay is shown or hidden.
  void onIosKeyboardDismissOverlayVisible(bool visible) {
    setState(() {
      _isIosKeyboardDismissOverlayVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: widget.appBar,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      drawer: widget.drawer,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );

    return ColoredBox(
      color: widget.safeAreaColor ?? widget.backgroundColor ?? theme(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: Platform.isIOS
            ? Padding(
                padding: _isIosKeyboardDismissOverlayVisible
                    ? const EdgeInsets.only(bottom: IosKeyboardDismissWrapper.HEIGHT)
                    : EdgeInsets.zero,
                child: scaffold,
              )

            /// Padding for the keyboard dismiss overlay is never needed on Android.
            : scaffold,
      ),
    );
  }
}
