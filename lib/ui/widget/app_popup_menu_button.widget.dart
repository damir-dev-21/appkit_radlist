import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppPopupMenuButton<T> extends StatefulWidget {
  final void Function(T item)? onSelected;
  final void Function()? onCanceled;
  final Widget? icon;
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;
  final Offset offset;
  final double? elevation;

  /// When used in [AppReorderableColumn], the widget gets deactivated when the popup
  /// menu is opened for some reason. Normally, we check that the widget is still mounted
  /// when a menu option is selected, but if this flag is set to true this check is
  /// not performed to fix the issue above.
  final bool ignoreWidgetDeactivation;

  const AppPopupMenuButton({
    Key? key,
    required this.itemBuilder,
    this.icon,
    this.onSelected,
    this.onCanceled,
    this.offset = Offset.zero,
    this.elevation,
    this.ignoreWidgetDeactivation = false,
  }) : super(key: key);

  @override
  _AppPopupMenuButtonState<T> createState() => _AppPopupMenuButtonState<T>();
}

class _AppPopupMenuButtonState<T> extends State<AppPopupMenuButton<T>> {
  void showButtonMenu() {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)?.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final List<PopupMenuEntry<T>> items = widget.itemBuilder(context);
    // Only show the menu if there is something to show
    if (items.isNotEmpty) {
      showMenu<T>(
        context: context,
        elevation: widget.elevation ?? popupMenuTheme.elevation,
        items: items,
        position: position,
        shape: RoundedRectangleBorder(
          borderRadius: theme(context).borderRadius,
        ),
        color: popupMenuTheme.color,
        // TODO: captureInheritedThemes: true,
      ).then<void>((T? newValue) {
        if (!widget.ignoreWidgetDeactivation && !mounted) return null;
        if (newValue == null) {
          if (widget.onCanceled != null) widget.onCanceled?.call();
          return null;
        }
        if (widget.onSelected != null) widget.onSelected?.call(newValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.icon ?? Icon(Icons.more_vert),
      tooltip: 'Показать меню',
      onPressed: showButtonMenu,
    );
  }
}
