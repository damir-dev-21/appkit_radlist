import 'package:flutter/material.dart';

/// Plays a scale transition when the [child] is shown/hidden.
class AppAnimatedScale extends StatefulWidget {
  final bool shown;
  final Widget child;
  final Duration duration;

  AppAnimatedScale({
    required this.shown,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  _AppAnimatedScaleState createState() => _AppAnimatedScaleState();
}

class _AppAnimatedScaleState extends State<AppAnimatedScale> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() => setState(() {}));

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    if (widget.shown) {
      animationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(AppAnimatedScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shown != widget.shown) {
      if (widget.shown) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: widget.child,
    );
  }
}
