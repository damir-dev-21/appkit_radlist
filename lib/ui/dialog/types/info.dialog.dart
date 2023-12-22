import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/ui/dialog/app_dialog.dart';
import 'package:appkit/ui/dialog/common/app_dialog_wrapper.dart';
import 'package:appkit/ui/dialog/common/dialog_header.widget.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String? title;
  final EDialogType type;
  final String? message;
  final List<Object>? messageValues;
  final Widget? content;
  final List<Widget>? actions;
  final bool? isCancelable;

  const InfoDialog({
    Key? key,
    this.title,
    this.message,
    this.messageValues,
    required this.type,
    this.content,
    this.actions,
    this.isCancelable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = this.content;
    final actions = this.actions;
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
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  content != null
                      ? content
                      : message != null
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                              alignment: Alignment.center,
                              child: TranslatedText(
                                message,
                                values: messageValues,
                                style: TextStyle(
                                  color: theme(context).altTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: actions == null
                          ? AppButton(
                              text: 'OK',
                              color: theme(context).altTextColor,
                              type: EButtonType.flat,
                              size: EButtonSize.small,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          : Wrap(
                              alignment: WrapAlignment.spaceAround,
                              verticalDirection: VerticalDirection.up,
                              children: actions,
                            ),
                    ),
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
