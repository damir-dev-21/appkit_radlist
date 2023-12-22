import 'package:flutter/material.dart';

import 'circular_reveal_animation.dart';

/// Uses a circular reveal animation to show/hide the given child when the value
/// of [shown] changes. Optional [center] argument can be used to specify
/// circular animation center. Child's center is used by default.
class AppCircularReveal extends StatefulWidget {
  final bool shown;
  final Widget child;
  final Duration duration;
  final Offset? center;

  AppCircularReveal({
    Key? key,
    required this.shown,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.center,
  }) : super(key: key);

  @override
  _AppCircularRevealState createState() => _AppCircularRevealState();
}

class _AppCircularRevealState extends State<AppCircularReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _completed = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      curve: Curves.easeIn,
      parent: _controller,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _completed = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AppCircularReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shown != widget.shown) {
      if (widget.shown) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      setState(() {
        _completed = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shown || !_completed) {
      return CircularRevealAnimation(
        child: widget.child,
        animation: _animation,
        centerOffset: widget.center,
      );
    } else {
      return Container();
    }
  }
}
