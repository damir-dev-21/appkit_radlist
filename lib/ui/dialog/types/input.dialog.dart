import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:appkit/ui/widget/form/app_input.widget.dart';
import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  final String? title;
  final String? label;
  final String? placeholder;
  final String? buttonText;
  final String? initialValue;
  final TextInputType? inputType;
  final IconData? prefixIcon;
  final void Function(String? value) onSubmit;
  final bool Function(String? value)? validator;
  final bool isPassword;

  const InputDialog({
    Key? key,
    required this.onSubmit,
    this.title,
    this.label,
    this.placeholder,
    this.buttonText,
    this.initialValue,
    this.inputType,
    this.prefixIcon,
    this.validator,
    this.isPassword = false,
  }) : super(key: key);

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _model = ValueModel<String>(initialVal: '');

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _model.val = widget.initialValue;
    }
    _model.addListener((val) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TranslatedText(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            AppInput(
              key: ValueKey('inputDialog.input'),
              model: _model,
              size: EAppInputSize.small,
              inputType: widget.inputType,
              prefixIcon: widget.prefixIcon,
              theme: EAppInputTheme.bordered,
              placeholder: widget.placeholder,
              autofocus: true,
              label: widget.label,
              isPassword: widget.isPassword,
            ),
            verticalSpace(28),
            AppButton(
              key: ValueKey('inputDialog.button'),
              text: widget.buttonText ?? '',
              disabled: widget.validator?.call(_model.val) == false,
              type: EButtonType.normal,
              padding: const EdgeInsets.all(12),
              onPressed: () {
                widget.onSubmit(_model.val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
