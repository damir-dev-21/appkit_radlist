import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/ui/dialog/app_dialog.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class _Params {
  final String? title;
  final IconData? iconData;
  final Color? color;

  _Params({
    this.title,
    this.iconData,
    this.color,
  });
}

class DialogHeader extends StatelessWidget {
  final EDialogType? type;
  final String? title;
  final bool? noIcon;

  const DialogHeader({
    Key? key,
    this.type,
    this.title,
    this.noIcon = false,
  }) : super(key: key);

  _Params getParams(BuildContext context) {
    String defaultTitle;
    Color color;
    IconData? iconData;

    switch (type) {
      case EDialogType.success:
        color = theme(context).successColor;
        defaultTitle = AppkitTr.label.success$;
        iconData = Icons.check_circle;
        break;
      case EDialogType.warning:
        color = theme(context).warningColor;
        defaultTitle = AppkitTr.label.warning$;
        iconData = Icons.error;
        break;
      case EDialogType.error:
        color = theme(context).errorColor;
        defaultTitle = AppkitTr.label.error$;
        iconData = Icons.cancel;
        break;
      default:
        color = theme(context).accentColor;
        defaultTitle = AppkitTr.label.attention$;
        break;
    }

    return _Params(
      title: title ?? defaultTitle,
      color: color,
      iconData: iconData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = getParams(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (params.iconData != null && noIcon == false)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(params.iconData, color: params.color, size: 23),
                ),
              Flexible(
                child: AutoSizeText(
                  translate(context, params.title ?? ''),
                  style: TextStyle(
                    color: params.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Divider(color: params.color, height: 1)
      ],
    );
  }
}
