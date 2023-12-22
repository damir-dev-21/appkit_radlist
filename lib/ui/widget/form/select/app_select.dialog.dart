import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/dialog/types/custom.dialog.dart';
import 'package:appkit/ui/model/select_option.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:appkit/ui/widget/form/select/app_list_select.widget.dart';
import 'package:flutter/material.dart';

class AppSelectDialog<T extends SelectOption> extends StatefulWidget {
  final String? title;
  final int? selectedId;
  final String? selectedName;
  final List<T>? options;
  final Paginator<T>? paginator;
  final bool? showClearButton;
  final String? textForEmptyOptions;
  final String? additionalButtonTitle;
  final VoidCallback? onAdditionalButtonPressed;
  final T? defaultOption;
  final String? submitButtonText;

  AppSelectDialog({
    Key? key,
    this.selectedId,
    this.selectedName,
    this.title,
    this.options,
    this.paginator,
    this.showClearButton,
    this.additionalButtonTitle,
    this.onAdditionalButtonPressed,
    this.textForEmptyOptions,
    this.defaultOption,
    this.submitButtonText,
  }) : super(key: key);

  @override
  _AppSelectDialogState<T> createState() => _AppSelectDialogState<T>();
}

class _AppSelectDialogState<T extends SelectOption> extends State<AppSelectDialog<T>> {
  late ValueModel<int> _selectedModel;
  late ValueModel<String> _selectedNameModel;

  @override
  void initState() {
    super.initState();

    _selectedModel = ValueModel(initialVal: widget.selectedId)
      ..addListener((val) {
        if (mounted) {
          setState(() {});
        }
      });

    _selectedNameModel = ValueModel<String>(initialVal: widget.selectedName);
  }

  @override
  Widget build(BuildContext context) {
    final additionalButtonTitle = widget.additionalButtonTitle;
    final onAdditionalButtonPressed = widget.onAdditionalButtonPressed;

    return CustomDialog(
      title: widget.title,
      isCancelable: false,
      topActions: widget.showClearButton == true && _selectedModel.val != widget.defaultOption?.id
          ? [
              AppButton(
                text: AppkitTr.action.reset$,
                onPressed: () {
                  Navigator.pop(context,
                      SimpleSelectOption(widget.defaultOption?.id, widget.defaultOption?.name));
                },
                type: EButtonType.flat,
                size: EButtonSize.small,
              ),
            ]
          : null,
      bottomActions: [
        if (additionalButtonTitle != null && onAdditionalButtonPressed != null)
          AppButton(
            text: additionalButtonTitle,
            type: EButtonType.bordered,
            onPressed: onAdditionalButtonPressed,
          ),
        AppButton(
          text: widget.submitButtonText ?? AppkitTr.action.select$,
          disabled: _selectedModel.val == null,
          onPressed: () {
            Navigator.pop(context, SimpleSelectOption(_selectedModel.val, _selectedNameModel.val));
          },
        )
      ],
      onClosePressed: () {
        Navigator.pop(context, SimpleSelectOption(widget.selectedId, widget.selectedName));
      },
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: widget.paginator == null && widget.options?.isEmpty == true
            ? _buildEmptyView(context)
            : AppListSelect(
                selectedModel: _selectedModel,
                selectedNameModel: _selectedNameModel,
                options: widget.options,
                paginator: widget.paginator,
              ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: TranslatedText(
          widget.textForEmptyOptions ?? AppkitTr.label.empty$,
          style: TextStyle(
            fontSize: 18,
            color: theme(context).labelColor,
          ),
        ),
      ),
    );
  }
}
