import 'package:another_flushbar/flushbar.dart';
import 'package:appkit/ui/message_display/snack_bar_wrapper.dart';
import 'package:appkit/ui/router/app_router.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum EMessageType {
  success,
  info,
  error,
}

enum MessageDisplayPosition {
  top,
  bottom,
}

abstract class MessageDisplay {
  static void debugMessage(String message) {
    Fluttertoast.showToast(msg: message, timeInSecForIosWeb: 10);
  }

  static void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: theme(context).surfaceColor.withOpacity(0.8),
      textColor: theme(context).inverseTextColor,
    );
  }

  static Future<T?> showSnackBar<T>({
    String? title,
    String? message,
    Widget? icon,
    String? actionText,
    bool persistent = false,
    Duration? duration,
    EMessageType type = EMessageType.info,
    Color? backgroundColor,
    Color? textColor,
    T Function()? onActionPressed,
    MessageDisplayPosition position = MessageDisplayPosition.bottom,
  }) {
    FlushbarPosition flushbarPosition;
    switch (position) {
      case MessageDisplayPosition.bottom:
        flushbarPosition = FlushbarPosition.BOTTOM;
        break;
      case MessageDisplayPosition.top:
        flushbarPosition = FlushbarPosition.TOP;
        break;
      default:
        flushbarPosition = FlushbarPosition.BOTTOM;
        break;
    }
    return createSnackBar(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      persistent: persistent,
      duration: duration,
      type: type,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onActionPressed,
      flushbarPosition: flushbarPosition,
    ).show(AppRouter.currentContext);
  }

  static SnackBarWrapper<T> createSnackBar<T>({
    String? title,
    String? message,
    Widget? icon,
    String? actionText,
    bool persistent = false,
    Duration? duration,
    EMessageType type = EMessageType.info,
    Color? backgroundColor,
    Color? textColor,
    T Function()? onActionPressed,
    FlushbarPosition? flushbarPosition,
  }) {
    final context = AppRouter.currentContext;
    final _theme = theme(context);

    Color color = _theme.accentColor;
    if (backgroundColor == null) {
      switch (type) {
        case EMessageType.success:
          color = _theme.successColor;
          break;
        case EMessageType.error:
          color = _theme.errorColor;
          break;
        case EMessageType.info:
        default:
          color = _theme.accentColor;
          break;
      }
    }

    final flushBar = Flushbar<T>(
      icon: icon,
      titleText: title != null
          ? Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      messageText: message != null
          ? Text(
              message,
              style: TextStyle(color: textColor ?? Colors.white),
            )
          : null,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(8),
      duration: persistent ? null : (duration ?? const Duration(seconds: 4)),
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeOutQuart,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      mainButton: actionText != null
          ? AppButton(
              text: actionText.toUpperCase(),
              color: _theme.inverseTextColor,
              type: EButtonType.flat,
              size: EButtonSize.small,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              fontSize: 12,
              onPressed: () {
                Navigator.pop(AppRouter.currentContext, onActionPressed?.call());
              },
            )
          : null,
      backgroundColor: backgroundColor ?? color.withAlpha(180),
      barBlur: 5,
      flushbarPosition: flushbarPosition ?? FlushbarPosition.BOTTOM,
    );

    return SnackBarWrapper.wrapFlushBar(flushBar);
  }
}
