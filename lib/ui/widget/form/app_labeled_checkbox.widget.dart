import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/animation/app_shake_animation.widget.dart';
import 'package:flutter/material.dart';

import 'app_checkbox.widget.dart';

/// A checkbox with a label.
class AppLabeledCheckbox extends StatelessWidget {
  final ValueModel<bool> model;
  final Widget label;
  final bool drawBorder;
  final bool disabled;

  const AppLabeledCheckbox({
    Key? key,
    required this.model,
    required this.label,
    this.drawBorder = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verticalSpace = MediaQuery.of(context).size.height < 600 ? 4.0 : 11.0;
    final themeData = theme(context);
    return AppShakeAnimation(
      animate: model.hasError,
      child: Material(
        color: disabled ? themeData.backgroundColor : themeData.surfaceColor,
        borderRadius: themeData.borderRadius,
        child: InkWell(
          borderRadius: themeData.borderRadius,
          onTap: disabled
              ? null
              : () {
                  model.val = (model.val != false) ? true : false;
                },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: model.val == true
                      ? disabled
                          ? themeData.dividerColor
                          : themeData.accentColor
                      : model.hasError
                          ? themeData.errorColor
                          : drawBorder
                              ? theme(context).backgroundColor
                              : Colors.transparent,
                ),
                borderRadius: themeData.borderRadius),
            padding: EdgeInsets.symmetric(vertical: verticalSpace, horizontal: 18),
            child: Row(
              children: <Widget>[
                AppCheckbox(
                  isChecked: model.val == true,
                  onChanged: disabled
                      ? null
                      : (value) {
                          model.val = value;
                        },
                ),
                horizontalSpace(14),
                Expanded(child: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
