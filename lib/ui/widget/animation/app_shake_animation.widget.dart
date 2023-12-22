import 'dart:math';

import 'package:flutter/material.dart';

/// Shakes the child widget along X axis when the [animate] argument becomes true.
class AppShakeAnimation extends StatefulWidget {
  /// Number of shifts to make.
  final int count;

  /// Duration of a single shift.
  final Duration duration;

  /// Should be set from false to true to trigger animation.
  final bool? animate;

  /// The amplitude of shaking.
  final double xOffset;

  /// The child widget to shake.
  final Widget child;

  const AppShakeAnimation({
    Key? key,
    required this.child,
    this.animate,
    this.count = 4,
    this.duration = const Duration(milliseconds: 100),
    this.xOffset = 8.0,
  }) : super(key: key);

  @override
  _AppShakeAnimationState createState() => _AppShakeAnimationState();
}

class _AppShakeAnimationState extends State<AppShakeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration * widget.count,
      vsync: this,
    );

    _offsetAnimation = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOutSine))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == true && oldWidget.animate == false) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(_getTranslation(), 0),
          child: widget.child,
        );
      },
    );
  }

  double _getTranslation() {
    final progress = _offsetAnimation.value;
    return sin(widget.count * progress * pi) * widget.xOffset;
  }
}
