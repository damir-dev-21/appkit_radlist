import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_icon.widget.dart';
import 'package:flutter/material.dart';

enum EAppCheckboxShape {
  square,
  circle,
}

class AppCheckbox extends StatelessWidget {
  final bool isChecked;
  final void Function(bool)? onChanged;
  final EAppCheckboxShape shape;

  const AppCheckbox({
    Key? key,
    this.onChanged,
    this.isChecked = false,
    this.shape = EAppCheckboxShape.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final isCircle = shape == EAppCheckboxShape.circle;
    final double size = isCircle ? 20 : 15;
    final borderColor = isChecked ? themeData.textColor! : themeData.disabledTextColor;
    final bgColor = isChecked ? themeData.textColor : themeData.surfaceColor;
    return InkWell(
      onTap: onChanged == null
          ? null
          : () {
              onChanged!(!isChecked);
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(2),
          border: isChecked ? null : Border.all(color: borderColor),
          color: isCircle ? Colors.transparent : bgColor,
        ),
        alignment: Alignment.center,
        child: isChecked ? AppIcon(isCircle ? 'ic_radio_check' : 'ic_check') : SizedBox.shrink(),
      ),
    );
  }
}
