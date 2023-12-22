import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// Render a default material card.
class AppCard extends StatelessWidget {
  /// The card's content.
  final Widget child;

  /// Function to invoke on tap.
  final VoidCallback? onTap;

  /// Function to invoke on long press.
  final VoidCallback? onLongPress;

  /// Card's elevation.
  final double elevation;

  final double? borderRadius;

  AppCard({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = 8,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    return Material(
      elevation: elevation,
      color: themeData.surfaceColor,
      shadowColor: themeData.shadowColor,
      borderRadius: borderRadius == null
          ? themeData.borderRadius
          : BorderRadius.all(Radius.circular(borderRadius ?? 0)),
      child: InkWell(
        borderRadius: themeData.borderRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
