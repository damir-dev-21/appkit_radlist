import 'package:appkit/ui/router/observer/route_observer.mixin.dart';
import 'package:flutter/material.dart';

class AppBounce extends StatefulWidget {
  final Widget child;
  final dynamic updateKey;

  AppBounce({required this.child, required this.updateKey});

  @override
  _AppBounceState createState() => _AppBounceState();
}

class _AppBounceState extends State<AppBounce>
    with SingleTickerProviderStateMixin, RouteObserverMixin {
  late AnimationController _controller;
  late Animation<double> _scaleUpAnimation;

  bool _isInitialized = false;

  /// Flag used to avoid animating the widget if the navigator was just popped.
  bool _didPopNext = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleUpAnimation = _controller.drive(Tween<double>(begin: 1, end: 1.5));

    _animate();
  }

  @override
  void didUpdateWidget(AppBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.microtask(() {
      if (!_didPopNext) {
        if (oldWidget.updateKey != widget.updateKey && _isInitialized) {
          _animate();
        }
      }

      _didPopNext = false;
    });
    _isInitialized = true;
  }

  @override
  void didPopNext(Route<dynamic> next) {
    super.didPopNext(next);
    _didPopNext = true;
  }

  void _animate() async {
    await _controller.forward();
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleUpAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleUpAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
