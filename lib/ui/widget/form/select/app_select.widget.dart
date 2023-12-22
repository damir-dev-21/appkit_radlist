import 'dart:math';

import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/model/select_option.dart';
import 'package:appkit/ui/responsive/widget/responsive_builder.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/soft_keyboard.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/animation/app_shake_animation.widget.dart';
import 'package:flutter/material.dart';
import 'app_select.screen.dart';
import 'package:collection/collection.dart';

/// An input field that lets the user select one option of several.
class AppSelect<T extends SelectOption> extends StatelessWidget {
  /// The label string to be shown above the select input.
  final String? label;

  /// The placeholder string to be shown inside the input.
  final String? placeholder;

  /// List of select options.
  final List<T>? options;

  /// If the list of options is paginated with an async data source, provide [paginator]
  /// instead of [options].
  final Paginator<T>? paginator;

  /// The model object for the currently selected option.
  final ValueModel<int> selectedModel;

  /// The model object for the currently selected option's name
  /// (is needed to display selected option's name if paginator is provided)
  final ValueModel<String>? selectedNameModel;

  /// Show a red star next to the label signifying that the field is required.
  final bool showRequired;

  /// If true, then the select will not be interactable, and will be grayed out.
  final bool disabled;

  /// If true, then the user will be given the option to clear the current selection.
  final bool clearable;

  /// On phones, the additional button is rendered as a FAB. This icon will be shown
  /// on this button.
  final Widget? additionalButtonIcon;

  /// On tablets the additional button is rendered as a regular button. This will be
  /// the title of this button.
  final String? additionalButtonTitle;

  /// The callback to be invoked when the additional button is pressed.
  final VoidCallback? onAdditionalButtonPressed;

  /// Can change default text if options are empty.
  final String? textForEmptyOptions;

  /// Alternative onTap behavior
  final VoidCallback? onTap;

  const AppSelect({
    Key? key,
    this.label,
    this.placeholder,
    required this.selectedModel,
    this.selectedNameModel,
    this.options,
    this.paginator,
    this.showRequired = false,
    this.disabled = false,
    this.clearable = false,
    this.additionalButtonIcon,
    this.additionalButtonTitle,
    this.onAdditionalButtonPressed,
    this.textForEmptyOptions,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

  Widget _buildLabel(BuildContext context) {
    String? label;
    final validationError = selectedModel.validationError;
    if (validationError != null) {
      label = translate(context, validationError.message, values: validationError.formatValues);
    } else {
      label = this.label ?? selectedModel.fieldName;
      if (label != null) {
        label = translate(context, label);
      }
    }

    final _theme = theme(context);
    return Row(
      children: <Widget>[
        if (showRequired) Text('* ', style: TextStyle(color: _theme.errorColor)),
        Text(
          label ?? '',
          style: TextStyle(
            color: _hasError ? _theme.errorColor : _theme.labelColor,
          ),
        ),
      ],
    );
  }

  bool get _hasError => selectedModel.validationError != null;

  Widget _buildField(BuildContext context) {
    final selectedName = _getSelectedName();

    final themeData = theme(context);
    final borderRadius = themeData.smallBorderRadius;

    final backgroundColor = _hasError
        ? themeData.errorColor
        : (disabled ? themeData.disabledColor : themeData.surfaceColor);

    return AppShakeAnimation(
      animate: _hasError,
      child: Material(
        borderRadius: borderRadius,
        elevation: 0,
        color: backgroundColor,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: disabled ? null : onTap ?? () => _openSelectScreen(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: _buildTextWidget(context, selectedName),
          ),
        ),
      ),
    );
  }

  Widget _buildTextWidget(BuildContext context, String? selectedName) {
    final themeData = theme(context);
    if (onTap == null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: TranslatedText(
              selectedName ?? placeholder ?? '',
              style: TextStyle(
                fontSize: 17,
                color: _getTextColor(context, selectedName),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          horizontalSpace(8),
          ResponsiveBuilder(
            phone: (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _hasError ? themeData.inverseTextColor.withOpacity(0.8) : null,
              ),
            ),
            tablet: (_) => Transform.rotate(
              angle: pi / 2,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _hasError ? themeData.inverseTextColor.withOpacity(0.8) : null,
              ),
            ),
          ),
        ],
      );
    } else {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          selectedName ?? placeholder ?? '',
          style: TextStyle(
            fontSize: 17,
            color: _getTextColor(context, selectedName),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  Color? _getTextColor(BuildContext context, String? selectedName) {
    final themeData = theme(context);
    if (_hasError) {
      return themeData.inverseTextColor.withOpacity(0.6);
    } else if (selectedName == null) {
      return themeData.altTextColor;
    } else {
      return disabled ? themeData.disabledTextColor : null;
    }
  }

  String? _getSelectedName() {
    if (selectedNameModel != null) {
      return selectedNameModel?.val;
    } else {
      return selectedModel.val != null
          ? options
              ?.firstWhereOrNull(
                (it) => it.id == selectedModel.val,
              )
              ?.name
          : null;
    }
  }

  void _openSelectScreen(BuildContext context) async {
    // Need to close keyboard before navigating so that the available screen height
    // is calculated correctly on _AppSelectScreen.
    SoftKeyboard.close(context);

    final title = this.label ?? selectedModel.fieldName;

    final result = await AppSelectScreen.open(
      title: title ?? '',
      context: context,
      options: options,
      paginator: paginator,
      selectedId: selectedModel.val ?? -1,
      selectedName: _getSelectedName(),
      showClearButton: clearable,
      additionalButtonTitle: additionalButtonTitle,
      additionalButtonIcon: additionalButtonIcon,
      textForEmptyOptions: textForEmptyOptions,
    );

    if (result != null || clearable) {
      selectedModel.val = result?.id;
      selectedNameModel?.val = result?.name;
    }
  }
}
