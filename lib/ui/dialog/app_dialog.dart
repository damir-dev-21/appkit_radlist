import 'dart:async';

import 'package:appkit/ui/router/app_router.dart';
import 'package:flutter/material.dart';

import 'types/bottom_select.dialog.dart';
import 'types/confirm.dialog.dart';
import 'types/custom.dialog.dart';
import 'types/info.dialog.dart';
import 'types/input.dialog.dart';
import 'types/tabbed_custom.dialog.dart';

const _TRANSITION_DURATION = Duration(milliseconds: 100);

enum EDialogType { success, info, warning, error }

typedef Widget TransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

abstract class AppDialog {
  AppDialog._();

  static Future<void> success({
    String? title,
    required String message,
    bool? isCancelable,
  }) {
    return alert(
      title: title,
      message: message,
      type: EDialogType.success,
      isCancelable: isCancelable,
    );
  }

  static Future<void> info({
    String? title,
    required String message,
    bool? isCancelable,
  }) {
    return alert(
      title: title,
      message: message,
      type: EDialogType.info,
      isCancelable: isCancelable,
    );
  }

  static Future<void> warning({
    String? title,
    required String message,
    bool? isCancelable,
  }) {
    return alert(
      title: title,
      message: message,
      type: EDialogType.warning,
      isCancelable: isCancelable,
    );
  }

  static Future<void> error({
    String? title,
    required String message,
    List<Object>? messageValues,
    bool? isCancelable,
  }) {
    return alert(
      title: title,
      message: message,
      messageValues: messageValues,
      type: EDialogType.error,
      isCancelable: isCancelable,
    );
  }

  static Future<T?> alert<T>({
    String? title,
    String? message,
    List<Object>? messageValues,
    required EDialogType type,
    Widget? content,
    List<Widget>? actions,
    bool? isCancelable = true,
  }) {
    return AppRouter.push<T>(_routeBuilder((context) {
      return InfoDialog(
        title: title,
        type: type,
        message: message?.trim(),
        messageValues: messageValues,
        content: content,
        actions: actions,
        isCancelable: isCancelable,
      );
    }));
  }

  static Future<bool> confirm({
    String? title,
    String? message,
    Widget? content,
    EDialogType type = EDialogType.warning,
    void Function()? onConfirm,
    bool isCancelable = true,
    String confirmBtnText = 'Да',
    String rejectBtnText = 'Нет',
    Color? confirmBtnColor,
    Color? rejectBtnColor,
  }) {
    return AppRouter.push<bool>(_routeBuilder<bool>(
      (context) => ConfirmDialog(
        title: title,
        message: message,
        content: content,
        onConfirm: onConfirm,
        confirmBtnText: confirmBtnText,
        rejectBtnText: rejectBtnText,
        confirmBtnColor: confirmBtnColor,
        rejectBtnColor: rejectBtnColor,
        type: type,
        isCancelable: isCancelable,
      ),
      isCancelable: isCancelable,
    )).then((result) => result ?? false);
  }

  /// Show a fully custom dialog.
  static Future<T?> showFullyCustom<T>(WidgetBuilder dialogBuilder) {
    return AppRouter.push<T>(_routeBuilder<T>(dialogBuilder));
  }

  /// Show a dialog with custom content.
  /// [title] and [titleWidget] will be shown on tablets on top of the dialog.
  /// [child] is the content of the dialog
  /// [topActions] will be shown on tablets in the top right corner of the dialog
  /// [bottomActions] will be shown on tablets on the bottom of the dialog.
  /// [insetPadding] will be respected on phones and defines the padding between the
  ///     edge of the screen and the dialog itself.
  /// If [isCancelable] is true, then the dialog can be closed by tapping outside of it.
  /// If [showCloseButton] is true, then a close button is rendered.
  static Future<T?> showCustomContent<T>({
    String? title,
    Widget? titleWidget,
    required Widget child,
    List<Widget>? topActions,
    List<Widget>? bottomActions,
    EdgeInsets insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    bool isCancelable = true,
    bool showCloseButton = true,
  }) {
    return AppRouter.push<T>(_routeBuilder<T>(
      (context) => CustomDialog(
        title: title,
        titleWidget: titleWidget,
        child: child,
        topActions: topActions,
        bottomActions: bottomActions,
        insetPadding: insetPadding,
        isCancelable: isCancelable,
        showCloseButton: showCloseButton,
      ),
    ));
  }

  /// Show an interface with multiple dialogs ([children]), each of which is rendered
  /// in a separate tab.
  static void showTabbedDialog({
    required List<Widget> children,
    EdgeInsets insetPadding = const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
  }) {
    AppRouter.push(_routeBuilder(
      (context) => TabbedCustomDialog(
        children: children,
        insetPadding: insetPadding,
      ),
    ));
  }

  static void showInputDialog({
    required String title,
    required void Function(String? value) onSubmit,
    String? label,
    String? placeholder,
    String? buttonText,
    String? initialValue,
    TextInputType? inputType,
    IconData? prefixIcon,
    bool Function(String? value)? validator,
    bool isPassword = false,
  }) {
    showCustomContent(
      child: InputDialog(
        title: title,
        onSubmit: onSubmit,
        label: label,
        placeholder: placeholder,
        buttonText: buttonText,
        initialValue: initialValue,
        inputType: inputType,
        prefixIcon: prefixIcon,
        validator: validator,
        isPassword: isPassword,
      ),
      insetPadding: const EdgeInsets.all(16),
    );
  }

  static Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    BuildContext? context,
  }) {
    final currentContext = AppRouter.currentContext;

    return showModalBottomSheet(
      isScrollControlled: isScrollControlled,
      context: context ?? currentContext,
      builder: builder,
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
    );
  }

  static Future<BottomSelectItem?> showBottomSelect({
    required String title,
    required List<BottomSelectItem> items,
    required FutureOr<bool> Function(BottomSelectItem item) onItemTapped,
  }) {
    return showBottomSheet(
      builder: (_) => BottomSelectDialog(
        title: title,
        items: items,
        onItemTapped: onItemTapped,
      ),
    );
  }

  static PageRouteBuilder<T> _routeBuilder<T>(
    WidgetBuilder pageBuilder, {
    bool isCancelable = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, _, __) => pageBuilder(context),
      barrierDismissible: isCancelable,
      transitionDuration: _TRANSITION_DURATION,
      reverseTransitionDuration: _TRANSITION_DURATION,
      transitionsBuilder: _transitionsBuilder(),
      opaque: false,
    );
  }

  static TransitionsBuilder _transitionsBuilder() {
    return (_, animation, __, child) => FadeTransition(
          opacity: Tween(
            begin: 0.2,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOut)).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 1.1,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation),
            child: child,
          ),
        );
  }
}
