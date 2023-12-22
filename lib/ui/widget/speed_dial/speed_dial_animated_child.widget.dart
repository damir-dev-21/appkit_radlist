import 'dart:ui';

import 'package:appkit/common/extension/number.extensions.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_icon.widget.dart';
import 'package:appkit/ui/widget/util/app_triangle.widget.dart';
import 'package:flutter/material.dart';

import 'speed_dial_child.dart';

class SpeedDialAnimatedChild extends AnimatedWidget {
  final int? index;
  final SpeedDialChild? speedDialChild;

  final VoidCallback? toggleChildren;
  final String? heroTag;

  SpeedDialAnimatedChild({
    Key? key,
    required Animation<double> animation,
    this.index,
    this.speedDialChild,
    this.toggleChildren,
    this.heroTag,
  }) : super(key: key, listenable: animation);

  Widget? _buildLabel(BuildContext context) {
    if (speedDialChild?.label == null && speedDialChild?.labelWidget == null) {
      return null;
    }

    final Animation<double> animation = listenable as Animation<double>;
    final animationFraction = animation.value / (speedDialChild?.size ?? 1);

    if (animationFraction < 0.7) {
      return null;
    }

    final widget = speedDialChild?.labelWidget ?? _buildDefaultLabel(context);

    return Transform.translate(
      offset: Offset(lerpDouble(16, -4, animationFraction) ?? 0, 0),
      child: Opacity(
        opacity: animationFraction.mapInterval(0.7, 1, 0, 1),
        child: widget,
      ),
    );
  }

  Widget _buildDefaultLabel(BuildContext context) {
    return GestureDetector(
      onTap: _performAction,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: speedDialChild?.labelBackgroundColor ?? theme(context).accentColor,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
            child: Text(
              speedDialChild?.label ?? '',
              style: speedDialChild?.labelStyle ??
                  TextStyle(
                    color: theme(context).accentForegroundColor,
                    fontSize: 14,
                  ),
            ),
          ),
          RotatedBox(
            quarterTurns: 1,
            child: AppTriangle(
              color: speedDialChild?.labelBackgroundColor ?? theme(context).accentColor,
              width: 11.3,
              height: 5.6,
            ),
          ),
        ],
      ),
    );
  }

  void _performAction() {
    if (speedDialChild?.onTap != null) speedDialChild?.onTap?.call();
    toggleChildren?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    final label = _buildLabel(context);
    final icon = speedDialChild?.iconName;
    final Widget buttonChild = Container(
      width: animation.value,
      height: animation.value,
      alignment: Alignment.center,
      child: speedDialChild?.child ??
          (icon != null
              ? AppIcon(
                  icon,
                  width: 26,
                  color: theme(context).accentForegroundColor,
                )
              : null) ??
          Container(),
    );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (label != null) label,
          Container(
            width: speedDialChild?.size,
            height: speedDialChild?.size,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 6),
            child: Transform.scale(
              scale: animation.value / (speedDialChild?.size ?? 1),
              child: FloatingActionButton(
                heroTag: heroTag,
                onPressed: _performAction,
                backgroundColor: speedDialChild?.backgroundColor ?? theme(context).accentColor,
                foregroundColor: speedDialChild?.foregroundColor,
                elevation: speedDialChild?.elevation ?? 6.0,
                child: buttonChild,
              ),
            ),
          )
        ],
      ),
    );
  }
}
