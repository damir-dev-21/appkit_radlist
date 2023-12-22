import 'dart:async';
import 'dart:io';

import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/soft_keyboard.dart';
import 'package:appkit/ui/widget/app_frosted_blur.widget.dart';
import 'package:appkit/ui/widget/app_scaffold.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

/// Wraps an input [child] so that when the input is focused and the keyboard
/// opens on iOS, an overlay widget is displayed on top of the keyboard
/// with a button that allows the user to dismiss the keyboard.
///
/// This is necessary on iOS devices when a number keyboard is shown, because
/// it doesn't have a dismiss button by default.
class IosKeyboardDismissWrapper extends StatefulWidget {
  static const HEIGHT = 54.0;

  final Widget child;
  final FocusNode focusNode;
  final bool enabled;

  const IosKeyboardDismissWrapper({
    Key? key,
    required this.child,
    required this.focusNode,
    this.enabled = true,
  }) : super(key: key);

  @override
  _IosKeyboardDismissWrapperState createState() => _IosKeyboardDismissWrapperState();
}

class _IosKeyboardDismissWrapperState extends State<IosKeyboardDismissWrapper> {
  OverlayEntry? _overlayEntry;
  late StreamSubscription<bool> _keyboardVisibilitySubscription;

  @override
  void initState() {
    super.initState();
    if (!Platform.isIOS) {
      return;
    }
    _keyboardVisibilitySubscription = KeyboardVisibilityController().onChange.listen((isVisible) {
      if (isVisible == false) {
        _hideOverlay();
      }
    });
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      widget.focusNode.removeListener(_onFocusChanged);
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    final hasFocus = widget.focusNode.hasFocus;
    if (hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (!widget.enabled) {
      return;
    }
    if (_overlayEntry != null) {
      return;
    }

    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (c) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: MediaQuery.of(c).viewInsets.bottom,
        child: _IosKeyboardDismissView(
          inputContext: context,
        ),
      );
    });
    final overlayEntry = _overlayEntry;
    if (overlayEntry != null) overlayState.insert(overlayEntry);

    AppScaffold.of(context)?.onIosKeyboardDismissOverlayVisible(true);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    AppScaffold.of(context)?.onIosKeyboardDismissOverlayVisible(false);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _IosKeyboardDismissView extends StatelessWidget {
  /// The context that is used to build the wrapper widget, used to close the keyboard.
  /// This works better than the context passed to this widget.
  final BuildContext inputContext;

  _IosKeyboardDismissView({
    Key? key,
    required this.inputContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppFrostedFilter(
      opacity: 0.7,
      color: theme(context).surfaceColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme(context).shadowColor, width: 1)),
        ),
        width: double.infinity,
        height: IosKeyboardDismissWrapper.HEIGHT,
        alignment: Alignment.centerRight,
        child: CupertinoButton(
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          onPressed: () {
            SoftKeyboard.close(inputContext);
          },
          child: TranslatedText(
            AppkitTr.action.done$,
            style: TextStyle(
              color: theme(context).accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
