import 'package:appkit/ui/widget/app_frosted_blur.widget.dart';
import 'package:flutter/material.dart';

class SpeedDialBackgroundOverlay extends AnimatedWidget {
  final Color color;
  final double opacity;
  final double? blurRadius;

  SpeedDialBackgroundOverlay({
    Key? key,
    required Animation<double> animation,
    this.color = Colors.white,
    this.opacity = 0.8,
    this.blurRadius,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return AppFrostedFilter(
      color: color,
      blurRadius: blurRadius,
      opacity: opacity * animation.value,
      child: Container(),
    );
  }
}
