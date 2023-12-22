import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// A rounded colored badge with text rendered inside.
class AppBadge extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? color;
  final EdgeInsets? padding;
  final Widget? leadingWidget;

  const AppBadge({
    Key? key,
    required this.text,
    this.textColor,
    this.leadingWidget,
    this.color,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leadingWidget = this.leadingWidget;
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? theme(context).warningColor,
        borderRadius: BorderRadius.circular(100),
      ),
      constraints: BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingWidget != null) leadingWidget,
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
