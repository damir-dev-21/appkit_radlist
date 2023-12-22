import 'dart:math';

import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppLinearProgressIndicator extends StatefulWidget {
  final Color? color;
  final double value;
  final double height;

  const AppLinearProgressIndicator({
    Key? key,
    this.color,
    required this.value,
    this.height = 5,
  }) : super(key: key);

  @override
  _AppLinearProgressIndicatorState createState() => _AppLinearProgressIndicatorState();
}

class _AppLinearProgressIndicatorState extends State<AppLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  Color? _backgroundColor;
  Color? _color;

  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _controller?.addListener(() {
      setState(() {});
    });

    _animation = _createAnimation(widget.value, widget.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color = widget.color ?? theme(context).accentColor;
    _backgroundColor = _color?.withAlpha(50);
  }

  @override
  void didUpdateWidget(AppLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = _createAnimation(oldWidget.value, widget.value);
      _controller?.reset();
      _controller?.forward();
    }
  }

  Animation<double> _createAnimation(double begin, double end) {
    return Tween(begin: begin, end: end)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: widget.height,
          width: double.infinity,
          color: _backgroundColor,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: min(_animation?.value ?? 0, 1.0),
            child: Container(
              color: _color,
              height: widget.height,
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
