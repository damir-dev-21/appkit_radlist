import 'package:flutter/material.dart';

/// Displays an icon button if the Navigator for the current context can be popped.
class AppBackButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? icon;
  final Color? color;

  const AppBackButton({
    Key? key,
    this.onPressed,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator.canPop(context)
        ? IconButton(
            icon: icon ?? Icon(Icons.arrow_back_ios, color: color),
            onPressed: () {
              Navigator.maybePop(context);
              onPressed?.call();
            },
          )
        : SizedBox.shrink();
  }
}
