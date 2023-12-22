import 'dart:ui';

import 'package:flutter/material.dart';

/// Blurs the background behind [child].
class AppFrostedFilter extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;
  final double blurRadius;

  const AppFrostedFilter({
    Key? key,
    required this.child,
    Color? color,
    this.opacity = 0.4,
    double? blurRadius,
  })  : this.color = color ?? Colors.white,
        this.blurRadius = blurRadius ?? 5.0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
          ),
          child: child,
        ),
      ),
    );
  }
}
