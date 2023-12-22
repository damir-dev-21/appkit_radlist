import 'package:flutter/material.dart';

class AppAnimatedWidth extends StatefulWidget {
  final bool shown;
  final Widget child;
  final Duration duration;
  final double? height;

  AppAnimatedWidth({
    required this.shown,
    required this.child,
    this.height,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  _AppAnimatedWidthState createState() => _AppAnimatedWidthState();
}

class _AppAnimatedWidthState extends State<AppAnimatedWidth> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      child: widget.shown ? widget.child : SizedBox(height: widget.height ?? 0, width: 0),
    );
  }
}
