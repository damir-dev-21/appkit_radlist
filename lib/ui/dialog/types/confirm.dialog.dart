import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/ui/dialog/app_dialog.dart';
import 'package:appkit/ui/dialog/common/app_dialog_wrapper.dart';
import 'package:appkit/ui/dialog/common/dialog_header.widget.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final void Function()? onConfirm;
  final String confirmBtnText;
  final String rejectBtnText;
  final Color? confirmBtnColor;
  final Color? rejectBtnColor;
  final EDialogType type;
  final bool isCancelable;

  const ConfirmDialog({
    Key? key,
    this.title,
    this.message,
    this.content,
    this.onConfirm,
    required this.confirmBtnText,
    required this.rejectBtnText,
    this.confirmBtnColor,
    this.rejectBtnColor,
    this.type = EDialogType.warning,
    this.isCancelable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = this.content;
    final message = this.message;

    return AppDialogWrapper(
      isCancelable: isCancelable,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            type: type,
            title: title,
          ),
          if (content != null) content,
          if (message != null)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 14),
              child: TranslatedText(
                message,
                style: TextStyle(
                  color: theme(context).altTextColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.center,
                verticalDirection: VerticalDirection.up,
                children: <Widget>[
                  AppButton(
                    text: rejectBtnText,
                    color: rejectBtnColor ?? theme(context).altTextColor,
                    type: EButtonType.flat,
                    size: EButtonSize.small,
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  AppButton(
                    text: confirmBtnText,
                    color: confirmBtnColor ?? theme(context).errorColor,
                    type: EButtonType.flat,
                    size: EButtonSize.small,
                    onPressed: () {
                      Navigator.pop(context, true);
                      nextFrame(() {
                        onConfirm?.call();
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
