import 'dart:math';

import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

const ANIMATION_DURATION = Duration(milliseconds: 400);
const _DEFAULT_SIZE = 32.0;

class AppLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double? strokeWidth;
  final Duration animationDuration;

  AppLoadingIndicator({
    this.color,
    double? size = _DEFAULT_SIZE,
    this.strokeWidth,
    this.animationDuration = ANIMATION_DURATION,
  }) : this.size = size ?? _DEFAULT_SIZE;

  @override
  State<StatefulWidget> createState() =>
      _AppLoadingIndicatorState(size, color ?? Colors.blueAccent);
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  final double? size;
  Color? color;
  late AnimationController _positionAnimation;

  _AppLoadingIndicatorState(this.size, this.color);

  @override
  void initState() {
    super.initState();
    _positionAnimation = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _positionAnimation.repeat();
  }

  @override
  void dispose() {
    _positionAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? theme(context).accentColor;
    final size = this.size ?? _DEFAULT_SIZE;

    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _Painter(
            _positionAnimation.value * 2 * pi,
            color,
            strokeWidth: widget.strokeWidth,
            size: size,
          ),
          child: SizedBox(
            width: size,
            height: size,
          ),
        );
      },
    );
  }
}

class _Painter extends CustomPainter {
  final double position;
  final Color _color;
  final double? strokeWidth;
  final double? size;

  _Painter(
    this.position,
    this._color, {
    this.strokeWidth,
    this.size,
  });

  var _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final size = this.size ?? canvasSize.width;
    var center = Offset(size / 2, size / 2);
    var radius = size / 2;
    var rect = Rect.fromCircle(center: center, radius: radius);
    _paint.strokeWidth = strokeWidth ?? size / 10;
    _paint.color = _color.withAlpha(100);

    canvas.drawArc(rect, 0, 2 * pi, false, _paint);

    _paint.color = _color;
    canvas.drawArc(rect, position, pi / 2, false, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
