import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:flutter/material.dart';
import 'app_switch.widget.dart';

/// A switch with a label.
class AppLabeledSwitch extends StatelessWidget {
  final Widget label;
  final ValueModel<bool> model;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool disabled;

  AppLabeledSwitch({
    Key? key,
    required this.label,
    required this.model,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    return Material(
      color: themeData.surfaceColor,
      borderRadius: borderRadius ?? themeData.smallBorderRadius,
      child: InkWell(
        borderRadius: borderRadius ?? themeData.smallBorderRadius,
        onTap: disabled
            ? null
            : () {
                model.val = (model.val != false) ? true : false;
              },
        child: Padding(
          padding: padding,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Opacity(
                  opacity: disabled ? 0.5 : 1,
                  child: label,
                ),
              ),
              horizontalSpace(21),
              AppSwitch(
                isSwitched: model.val == true,
                disabled: disabled,
                onChanged: (value) {
                  model.val = value;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
