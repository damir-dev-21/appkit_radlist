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
    final double size = isCircle ? 24 : 15;
    final borderColor =
        isChecked ? themeData.textColor! : themeData.disabledTextColor;
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
          border: isChecked ? null : Border.all(color: Colors.white, width: 1),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: isChecked
            ? AppIcon(
                isCircle ? 'ic_radio_check' : 'ic_check',
                color: Colors.black,
              )
            : AppIcon(
                isCircle ? 'ic_radio_check' : 'ic_check',
                color: Colors.black.withOpacity(.3),
              ),
      ),
    );
  }
}

class AppCheckboxSort extends StatelessWidget {
  final bool isChecked;
  final void Function(bool)? onChanged;
  final EAppCheckboxShape shape;

  const AppCheckboxSort({
    Key? key,
    this.onChanged,
    this.isChecked = false,
    this.shape = EAppCheckboxShape.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final isCircle = shape == EAppCheckboxShape.circle;
    final double size = isCircle ? 24 : 15;
    final borderColor =
        isChecked ? themeData.textColor! : themeData.disabledTextColor;
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
            border: isChecked
                ? Border.all(color: Colors.white, width: 1)
                : Border.all(color: Colors.white, width: 1),
            color: isChecked ? Colors.white : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.done,
              size: 15, color: isChecked ? Colors.black : Colors.transparent)
          // AppIcon(
          //   isCircle ? 'ic_radio_check' : 'ic_check',
          //   color: isChecked ? Colors.white : Colors.transparent,
          // )
          ),
    );
  }
}

class AppCheckboxSortDisabled extends StatelessWidget {
  final bool isChecked;
  final void Function(bool)? onChanged;
  final EAppCheckboxShape shape;

  const AppCheckboxSortDisabled({
    Key? key,
    this.onChanged,
    this.isChecked = false,
    this.shape = EAppCheckboxShape.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final isCircle = shape == EAppCheckboxShape.circle;
    final double size = isCircle ? 24 : 15;
    final borderColor =
        isChecked ? themeData.textColor! : themeData.disabledTextColor;
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
            border: isChecked
                ? null
                : Border.all(color: Color.fromRGBO(153, 153, 153, 1), width: 1),
            color: isChecked ? Colors.transparent : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: AppIcon(
            isCircle ? 'ic_radio_check' : 'ic_check',
            color: isChecked ? Colors.white : Colors.transparent,
          )),
    );
  }
}
