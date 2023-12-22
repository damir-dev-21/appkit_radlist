import 'package:flutter/material.dart';

/// Align the child at the bottom of the containing Stack, and draw a gradient
/// from transparent to white, top to bottom, unless [noGradient] is true.
class AppAlignBottom extends StatelessWidget {
  final Widget child;

  /// If true, then no gradient will be rendered behind the child.
  final bool noGradient;

  const AppAlignBottom({
    Key? key,
    required this.child,
    this.noGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: noGradient
          ? child
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xaaffffff), Color(0xaaffffff), Color(0x00ffffff)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topLeft,
                ),
              ),
              child: child,
            ),
    );
  }
}
