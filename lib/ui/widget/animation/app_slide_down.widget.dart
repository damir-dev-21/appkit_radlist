import 'package:flutter/material.dart';

class AppSlideDown extends StatefulWidget {
  final Widget child;
  final bool shown;
  final Duration duration;

  const AppSlideDown({
    Key? key,
    required this.shown,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
  }) : super(key: key);

  @override
  _AppSlideDownState createState() => _AppSlideDownState();
}

class _AppSlideDownState extends State<AppSlideDown> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(begin: Offset(0, -1.1), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);

    if (widget.shown) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(AppSlideDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shown != widget.shown) {
      if (widget.shown) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
