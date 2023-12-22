import 'package:flutter/material.dart';

class AppAnimatedHeight extends StatefulWidget {
  final bool shown;
  final Widget child;
  final Duration duration;

  AppAnimatedHeight({
    required this.shown,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  _AppAnimatedHeightState createState() => _AppAnimatedHeightState();
}

class _AppAnimatedHeightState extends State<AppAnimatedHeight> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      child: widget.shown ? widget.child : SizedBox(width: double.infinity),
    );
  }
}
