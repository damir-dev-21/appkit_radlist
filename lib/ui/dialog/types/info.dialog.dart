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
                              padding:
                                  const EdgeInsets.fromLTRB(12, 28, 12, 12),
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

class InfoDialogCreateList extends StatefulWidget {
  final String? title;
  final EDialogType type;
  final String? message;
  final String? subMessage;
  final List<Object>? messageValues;
  final Widget? content;
  final List<Widget>? actions;
  final bool? isCancelable;

  const InfoDialogCreateList({
    Key? key,
    this.title,
    this.message,
    this.subMessage,
    this.messageValues,
    required this.type,
    this.content,
    this.actions,
    this.isCancelable = true,
  }) : super(key: key);

  @override
  State<InfoDialogCreateList> createState() => _InfoDialogCreateListState();
}

class _InfoDialogCreateListState extends State<InfoDialogCreateList> {
  TextEditingController _textController = TextEditingController();
  bool _showError = false;
  @override
  Widget build(BuildContext context) {
    final content = this.widget.content;
    final actions = this.widget.actions;
    final message = this.widget.message;
    final subMessage = this.widget.subMessage;
    return AppDialogCreateListWrapper(
      isCancelable: widget.isCancelable,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 15),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // DialogHeader(
              //   type: type,
              //   title: title,
              // ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Add list",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      content != null
                          ? content
                          : message != null && subMessage != null
                              ? Column(
                                  children: [
                                    Container(
                                      // padding:
                                      //     const EdgeInsets.fromLTRB(12, 28, 12, 12),
                                      alignment: Alignment.topLeft,
                                      child: TranslatedText(
                                        message,
                                        values: widget.messageValues,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        subMessage,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                153, 153, 153, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      child: TextFormField(
                                        controller: _textController,
                                        style: TextStyle(color: Colors.white),
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                            errorText: _showError
                                                ? "Email field is empty or does not match"
                                                : null,
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: "Add your email...",
                                            hintStyle: TextStyle(fontSize: 13),
                                            labelStyle: TextStyle(fontSize: 15),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                255, 255, 255, .1)),
                                      ),
                                    )
                                  ],
                                )
                              : SizedBox.shrink(),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Color.fromRGBO(153, 153, 153, 1),
                                        fontSize: 16),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    final emailPattern = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (_textController.text.isEmpty ||
                                        !emailPattern
                                            .hasMatch(_textController.text)) {
                                      setState(() {
                                        _showError = true;
                                      });
                                    } else {
                                      setState(() {
                                        _showError = false;
                                      });
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: Text(
                                    "Send",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
