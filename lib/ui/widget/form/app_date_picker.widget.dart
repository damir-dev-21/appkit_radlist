import 'package:appkit/common/extension/date_time.extensions.dart';
import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/util/format.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:appkit/ui/router/app_router.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDatePicker extends StatefulWidget {
  static Future<T?>? show<T>({
    required String label,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String? secondaryButtonText,
    void Function()? onSecondaryButtonPressed,
  }) {
    return showModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      context: AppRouter.currentContext,
      isScrollControlled: true,
      builder: (_) => AppDatePicker(
        label: label,
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
        secondaryButtonText: secondaryButtonText,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
      ),
    );
  }

  final String label;
  final DateTime? initialDate;
  final String? secondaryButtonText;
  final void Function()? onSecondaryButtonPressed;

  final DateTime? maxDate;
  final DateTime? minDate;

  const AppDatePicker({
    Key? key,
    required this.label,
    this.initialDate,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.maxDate,
    this.minDate,
  }) : super(key: key);

  @override
  _AppDatePickerState createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  String? _secondaryButtonText;

  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _secondaryButtonText = widget.secondaryButtonText;
    _date = widget.initialDate ?? DateTime.now().atStartOfDay;
    final minDate = widget.minDate;
    final maxDate = widget.maxDate;
    if (minDate != null && _date.isBefore(minDate)) {
      _date = minDate;
    } else if (maxDate != null && _date.isAfter(maxDate)) {
      _date = maxDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final isPhone = Responsive.isPhone(context);
    return Container(
      decoration: BoxDecoration(
        color: themeData.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(themeData.radius)),
      ),
      padding: const EdgeInsets.only(top: 21),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TranslatedText(widget.label),
            verticalSpace(4),
            Text(
              Format.dateHumanReadable(_date),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            verticalSpace(4),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 216, maxWidth: 250),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                maximumDate: widget.maxDate,
                minimumDate: widget.minDate,
                onDateTimeChanged: (value) {
                  setState(() {
                    _date = value;
                  });
                },
              ),
            ),
            FractionallySizedBox(
              widthFactor: isPhone ? null : 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        text: _secondaryButtonText ?? AppkitTr.action.cancel$,
                        height: 40,
                        backgroundColor: theme(context).disabledColor,
                        color: theme(context).textColor,
                        autoSizeText: true,
                        onPressed: widget.onSecondaryButtonPressed ??
                            () {
                              Navigator.pop(context);
                            },
                      ),
                    ),
                    horizontalSpace(28),
                    Expanded(
                      child: AppButton(
                        text: 'OK',
                        height: 40,
                        autoSizeText: true,
                        onPressed: () {
                          Navigator.pop(context, _date);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
