import 'dart:async';

import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_divider.widget.dart';
import 'package:appkit/ui/widget/app_framed_icon.dart';
import 'package:appkit/ui/widget/app_loading_indicator.dart';
import 'package:flutter/material.dart';

class BottomSelectItem {
  final int? id;
  final String title;
  final Color? color;
  final String? iconName;

  BottomSelectItem({
    this.id,
    required this.title,
    this.iconName,
    this.color,
  });
}

class BottomSelectDialog extends StatefulWidget {
  final String title;
  final List<BottomSelectItem> items;
  final FutureOr<bool> Function(BottomSelectItem item) onItemTapped;

  const BottomSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _BottomSelectDialogState createState() => _BottomSelectDialogState();
}

class _BottomSelectDialogState extends State<BottomSelectDialog> {
  int? _loadingItemId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) =>
          index == 0 ? _buildHeader(context) : _buildItem(context, widget.items[index - 1]),
      separatorBuilder: (_, index) => index == 0 ? SizedBox.shrink() : AppDivider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length + 1,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: TranslatedText(
        widget.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, BottomSelectItem item) {
    final _theme = theme(context);
    return AbsorbPointer(
      absorbing: _loadingItemId != null,
      child: Material(
        child: InkWell(
          onTap: () async {
            setState(() {
              _loadingItemId = item.id;
            });
            final result = await widget.onItemTapped(item);
            setState(() {
              _loadingItemId = null;
            });
            if (result == true) {
              Navigator.pop(context, item);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _loadingItemId == item.id
                    ? Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 11),
                        child: AppLoadingIndicator(
                          color: item.color ?? _theme.accentColor,
                          size: 24,
                        ),
                      )
                    : item.iconName != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 11),
                            child: AppFramedIcon(
                              item.iconName,
                              color: _loadingItemId != null ? _theme.disabledTextColor : item.color,
                              size: 35,
                            ),
                          )
                        : SizedBox.shrink(),
                TranslatedText(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: _loadingItemId != null ? _theme.disabledTextColor : item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
