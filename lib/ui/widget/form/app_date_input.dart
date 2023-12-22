import 'package:appkit/common/extension/date_time.extensions.dart';
import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/common/util/format.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/animation/app_shake_animation.widget.dart';
import 'package:appkit/ui/widget/app_icon.widget.dart';
import 'package:appkit/ui/widget/form/app_date_picker.widget.dart';
import 'package:appkit/ui/widget/form/app_date_range_picker.dart';
import 'package:flutter/material.dart';

class AppDateInput extends StatelessWidget {
  /// Input label.
  final String? label;

  /// Placeholder string rendered inside the input.
  final String placeholder;

  /// If true, then mark the field as required.
  final bool showRequired;

  /// The date.
  final ValueModel<DateTime>? model;

  /// The range of dates.
  final ValueModel<DateTimeRange>? rangeModel;

  /// The font size of the input.
  final double fontSize;

  /// If true, render as disabled and do not allow input.
  final bool disabled;

  /// If true, then build range date picker.
  final bool isRange;

  const AppDateInput({
    Key? key,
    this.model,
    this.rangeModel,
    this.label,
    this.placeholder = 'Выберите дату',
    this.showRequired = false,
    this.fontSize = 17,
    this.disabled = false,
    this.isRange = false,
  })  : assert(!isRange && model != null || isRange && rangeModel != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _buildLabel(context),
        ),
        _buildField(context),
        verticalSpace(6),
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    final _theme = theme(context);
    final borderRadius = _theme.smallBorderRadius;

    final backgroundColor =
        _hasError ? _theme.errorColor : (disabled ? _theme.disabledColor : _theme.surfaceColor);

    final textColor = _hasError ? _theme.inverseTextColor.withOpacity(0.6) : _theme.altTextColor;

    return AppShakeAnimation(
      animate: _hasError,
      child: Material(
        borderRadius: borderRadius,
        elevation: 0,
        color: backgroundColor,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: disabled ? null : () => _openDatePicker(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _buildDate(),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                horizontalSpace(8),
                AppIcon(
                  'ic_calendar',
                  color: _hasError ? _theme.inverseTextColor.withOpacity(0.8) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    String _label;
    final _model = isRange ? rangeModel : model;
    final validationError = _model!.validationError;
    if (validationError != null) {
      _label = translate(context, validationError.message, values: validationError.formatValues);
    } else {
      _label = this.label ?? _model.fieldName ?? '';
      if (label != null) {
        _label = translate(context, label!);
      }
    }

    final _theme = theme(context);
    return Row(
      children: <Widget>[
        if (showRequired) Text('* ', style: TextStyle(color: _theme.errorColor)),
        Text(
          _label,
          style: TextStyle(
            color: _hasError ? _theme.errorColor : _theme.labelColor,
          ),
        ),
      ],
    );
  }

  String _buildDate() {
    if (isRange) {
      if (isDatesSet) {
        return '${Format.date(rangeModel!.val?.start)} - ${Format.date(rangeModel!.val?.end)}';
      } else {
        return placeholder;
      }
    } else {
      return model!.val != null ? Format.date(model!.val) : placeholder;
    }
  }

  bool get isDatesSet => rangeModel!.val?.start != null && rangeModel!.val?.end != null;

  bool get _hasError {
    final _model = isRange ? rangeModel : model;
    return _model!.validationError != null;
  }

  void _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    if (isRange) {
      final result = await AppDateRangePicker.show(
        context: context,
        initialFirstDate: rangeModel!.val?.start ?? now,
        initialLastDate: rangeModel!.val?.end ?? now,
        firstDate: now.atStartOfDay,
        lastDate: DateTime(2100),
      );
      rangeModel!.val = result;
    } else {
      final result = await AppDatePicker.show(label: label ?? '');
      if (result is DateTime) {
        model!.val = result;
      }
    }
  }
}
