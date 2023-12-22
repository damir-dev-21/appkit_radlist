import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An icon button with a rounded frame around it.
class AppFramedIcon extends StatelessWidget {
  final String? name;
  final double size;
  final double iconWidth;
  final double? iconHeight;
  final double? borderRadius;
  final void Function()? onTap;
  final Color? color;
  final Color? iconColor;

  const AppFramedIcon(
    this.name, {
    Key? key,
    this.size = 35,
    this.iconWidth = 22,
    this.iconHeight,
    this.borderRadius,
    this.onTap,
    this.color,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final borderRadiusData = this.borderRadius;

    final borderRadius =
        borderRadiusData != null ? BorderRadius.circular(borderRadiusData) : themeData.borderRadius;

    final baseColor = color ?? themeData.accentColor;

    return Material(
      color: baseColor.withAlpha(30),
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: name != null
              ? SvgPicture.asset(
                  'assets/icon/$name.svg',
                  width: iconWidth,
                  height: iconHeight,
                  color: iconColor,
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
