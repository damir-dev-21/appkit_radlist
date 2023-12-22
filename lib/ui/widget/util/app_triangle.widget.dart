import 'package:flutter/material.dart';

/// Draws a triangle pointed up.
class AppTriangle extends StatelessWidget {
  /// Color of the triangle.
  final Color color;

  /// Color of the border of the triangle. If null, then no border is drawn.
  final Color? borderColor;

  /// Width of the triangle.
  final double width;

  /// Height of the triangle.
  final double height;

  const AppTriangle({
    Key? key,
    required this.color,
    required this.width,
    required this.height,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrianglePainter(
        color: color,
        borderColor: borderColor,
      ),
      size: Size(width, height),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color? borderColor;

  final _path = Path();
  final _paint = Paint()
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;

  final _borderPaint = Paint()
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  _TrianglePainter({
    required this.color,
    this.borderColor,
  }) {
    _paint.color = color;
    final borderColor = this.borderColor;
    if (borderColor != null) {
      _borderPaint.color = borderColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintTriangle(canvas, size, _paint, 2);

    if (borderColor != null) {
      _paintTriangle(canvas, size, _borderPaint, 0.8);
    }
  }

  void _paintTriangle(Canvas canvas, Size size, Paint paint, double offset) {
    _path
      ..reset()
      ..moveTo(0, size.height + offset)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height + offset);

    canvas.drawPath(_path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color || oldPainter.borderColor != borderColor;
  }
}
