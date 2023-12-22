// Original source code copied from https://github.com/darioielardi/flutter_speed_dial

import 'package:appkit/common/extension/list.extensions.dart';
import 'package:flutter/material.dart';

import 'speed_dial_animated_child.widget.dart';
import 'speed_dial_fab.widget.dart';
import 'speed_dial_background_overlay.widget.dart';
import 'speed_dial_child.dart';

export 'speed_dial_child.dart';

/// Builds the Speed Dial
class SpeedDial extends StatefulWidget {
  /// Children buttons, from the lowest to the highest.
  final List<SpeedDialChild> children;

  /// Used to get the button hidden on scroll. See examples for more info.
  final bool visible;

  /// The curve used to animate the button on scrolling.
  final Curve curve;

  final String? tooltip;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final ShapeBorder shape;

  final double marginRight;
  final double marginBottom;

  /// The color of the background overlay.
  final Color overlayColor;

  /// The opacity of the background overlay when the dial is open.
  final double overlayOpacity;

  /// The blur radius of the background overlay when the dial is open.
  final double overlayBlurRadius;

  /// The animated icon to show as the main button child. If this is provided the [child] is ignored.
  final AnimatedIconData? animatedIcon;

  /// The theme for the animated icon.
  final IconThemeData? animatedIconTheme;

  /// The child of the main button, ignored if [animatedIcon] is non [null].
  final Widget? child;

  /// Executed when the dial is opened.
  final VoidCallback? onOpen;

  /// Executed when the dial is closed.
  final VoidCallback? onClose;

  /// Executed when the dial is pressed. If given, the dial only opens on long press!
  final VoidCallback? onPress;

  /// If true user is forced to close dial manually by tapping main button. WARNING: If true, overlay is not rendered.
  final bool closeManually;

  /// The speed of the animation
  final int animationSpeed;

  SpeedDial({
    this.children = const [],
    this.visible = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.overlayOpacity = 0.8,
    this.overlayColor = Colors.white,
    this.overlayBlurRadius = 5.0,
    this.tooltip,
    this.heroTag,
    this.animatedIcon,
    this.animatedIconTheme,
    this.child,
    this.marginBottom = 16,
    this.marginRight = 14,
    this.onOpen,
    this.onClose,
    this.closeManually = false,
    this.shape = const CircleBorder(),
    this.curve = Curves.linear,
    this.onPress,
    this.animationSpeed = 150,
  });

  @override
  _SpeedDialState createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _open = false;
  bool _closed = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _calculateMainControllerDuration(),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _closed = true;
        });
      }
    });
  }

  Duration _calculateMainControllerDuration() => Duration(
      milliseconds:
          widget.animationSpeed + widget.children.length * (widget.animationSpeed / 5).round());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performAnimation() {
    if (!mounted) return;
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(SpeedDial oldWidget) {
    if (oldWidget.children.length != widget.children.length) {
      _controller.duration = _calculateMainControllerDuration();
    }

    super.didUpdateWidget(oldWidget);
  }

  void _toggleChildren() {
    var newValue = !_open;
    setState(() {
      _open = newValue;
      if (newValue) {
        _closed = false;
      }
    });
    if (newValue && widget.onOpen != null) widget.onOpen?.call();
    _performAnimation();
    if (!newValue && widget.onClose != null) widget.onClose?.call();
  }

  List<Widget> _getChildrenList() {
    final singleChildrenTween = 1.0 / widget.children.length;

    return widget.children
        .mapIndexed((SpeedDialChild child, int index) {
          final childAnimation = Tween(begin: 0.0, end: child.size).animate(
            CurvedAnimation(
              parent: this._controller,
              curve: Interval(0, singleChildrenTween * (index + 1)),
            ),
          );
          final heroTag = widget.heroTag;
          return SpeedDialAnimatedChild(
            animation: childAnimation,
            index: index,
            speedDialChild: child,
            toggleChildren: () {
              if (!widget.closeManually) _toggleChildren();
            },
            heroTag: heroTag != null ? '$heroTag-child-$index' : null,
          );
        })
        .reversed
        .toList();
  }

  Widget _renderOverlay() {
    return Positioned(
      right: -16.0,
      bottom: -16.0,
      top: _closed ? null : 0.0,
      left: _closed ? null : 0.0,
      child: GestureDetector(
        onTap: _toggleChildren,
        child: SpeedDialBackgroundOverlay(
          animation: _controller,
          color: widget.overlayColor,
          opacity: widget.overlayOpacity,
          blurRadius: widget.overlayBlurRadius,
        ),
      ),
    );
  }

  Widget _renderButton() {
    final animatedIcon = widget.animatedIcon;
    final child = animatedIcon != null
        ? AnimatedIcon(
            icon: animatedIcon,
            progress: _controller,
            color: widget.animatedIconTheme?.color,
            size: widget.animatedIconTheme?.size,
          )
        : widget.child;

    return Positioned(
      bottom: widget.marginBottom - 16,
      right: widget.marginRight - 16,
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ..._getChildrenList(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 2.0),
                child: SpeedDialFab(
                  visible: widget.visible,
                  tooltip: widget.tooltip,
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.foregroundColor,
                  elevation: widget.elevation,
                  onLongPress: _toggleChildren,
                  callback: (_open || widget.onPress == null) ? _toggleChildren : widget.onPress,
                  child: child,
                  heroTag: widget.heroTag,
                  shape: widget.shape,
                  curve: widget.curve,
                ),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      fit: StackFit.expand,
      // TODO: overflow: Overflow.visible,
      children: [
        if (!widget.closeManually) _renderOverlay(),
        _renderButton(),
      ],
    );
  }
}
