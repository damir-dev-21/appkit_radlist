import 'package:flutter/material.dart';

/// Animates changes between child widgets using a scale animation.
///
/// That is, when the [child] argument changes, the old child is scaled down and faded out,
/// while at the same time the new child is faded in and scaled up.
class AppScaleSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double scaleFraction;

  const AppScaleSwitcher({
    Key? key,
    this.duration = const Duration(milliseconds: 200),
    required this.child,
    this.scaleFraction = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          child: child,
          scale: scaleFraction != 0
              ? Tween(begin: scaleFraction, end: 1.0).animate(animation)
              : animation,
        ),
      ),
      child: child,
    );
  }
}
