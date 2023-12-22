import 'package:appkit/ui/util/ui_functions.dart';
import 'package:flutter/material.dart';

class AppSlideUp extends StatefulWidget {
  final Widget child;
  final bool shown;
  final Duration duration;
  final double initialOffset;

  const AppSlideUp({
    Key? key,
    required this.shown,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.initialOffset = 0,
  }) : super(key: key);

  @override
  _AppSlideUpState createState() => _AppSlideUpState();
}

class _AppSlideUpState extends State<AppSlideUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (mounted) {
        if (status == AnimationStatus.dismissed && !_isHidden) {
          setState(() {
            _isHidden = true;
          });
        } else if (_isHidden) {
          setState(() {
            _isHidden = false;
          });
        }
      }
    });

    nextFrame(() {
      final size = context.size;
      if (size != null) {
        final exitOffset = 1 - (widget.initialOffset / size.height);
        _animation = Tween<Offset>(begin: Offset(0, exitOffset), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(_controller);

        setState(() {});
      }
    });

    if (widget.shown) {
      _controller.value = 1;
      _isHidden = false;
    }
  }

  @override
  void didUpdateWidget(AppSlideUp oldWidget) {
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
      child: Opacity(
        opacity: _isHidden ? 0 : 1,
        child: widget.child,
      ),
    );
  }
}
