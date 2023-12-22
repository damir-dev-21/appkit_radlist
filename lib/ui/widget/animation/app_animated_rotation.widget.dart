import 'package:flutter/material.dart';

/// Animate the rotation of the [child].
class AppAnimatedRotation extends StatefulWidget {
  /// The current rotation angle in radians.
  final double angle;

  /// The child to rotate.
  final Widget child;

  /// Rotation animation duration.
  final Duration duration;

  AppAnimatedRotation({
    Key? key,
    required this.angle,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
  }) : super(key: key);

  @override
  _AppAnimatedRotationState createState() => _AppAnimatedRotationState();
}

class _AppAnimatedRotationState extends State<AppAnimatedRotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _angleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _angleAnimation = Tween(begin: widget.angle, end: widget.angle).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppAnimatedRotation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.angle != widget.angle) {
      _angleAnimation = Tween(begin: oldWidget.angle, end: widget.angle).animate(_controller);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angleAnimation,
      builder: (context, _) {
        return Transform.rotate(
          angle: _angleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
