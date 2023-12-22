import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/model/select_option.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/pagination/widget/app_paginated_list.widget.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/app_divider.widget.dart';
import 'package:flutter/material.dart';

/// Renders a list of options from which a single option can be selected.
class AppListSelect<T extends SelectOption> extends StatelessWidget {
  static const ITEM_HEIGHT = 66.0;

  AppListSelect({
    Key? key,
    required this.selectedModel,
    this.selectedNameModel,
    this.options,
    this.paginator,
    this.controller,
    this.padding,
    this.physics,
  })  : assert(options != null || paginator != null),
        super(key: key) {
    if (physics != null) {
      assert(options != null, 'Physics should be provided only together'
          ' with options parameter. Paginator has its own scroll physics');
    }
  }

  /// The list of options to select from.
  final List<T>? options;

  /// The model with the currently selected option's ID as the value.
  final ValueModel<int> selectedModel;

  /// The model with the currently selected option's name.
  final ValueModel<String>? selectedNameModel;

  /// Alternative to [options], if the list of options is paginated.
  final Paginator<T>? paginator;

  /// Scroll controller for the ListView.
  final ScrollController? controller;

  /// Padding for the list
  final EdgeInsets? padding;

  /// Scroll physics for [ListView] containing [options], must be null if
  /// [paginator] is provided instead of [options]
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final options = this.options;
    if (options != null) {
      return ListView.builder(
        controller: controller,
        itemCount: options.length,
        padding: padding,
        itemExtent: ITEM_HEIGHT,
        physics: physics,
        itemBuilder: (context, index) {
          final option = options[index];

          return _buildItem(context, option, index);
        },
      );
    } else {
      return AppPaginatedList<T>(
        scrollController: controller,
        padding: padding,
        paginator: paginator!,
        itemExtent: ITEM_HEIGHT,
        itemBuilder: (option, index) {
          return _buildItem(context, option, index);
        },
      );
    }
  }

  Widget _buildItem(BuildContext context, T option, int index) {
    return Column(
      key: ValueKey(option.id),
      children: [
        if (index > 0) AppDivider(),
        InkWell(
          onTap: () {
            selectedModel.val = option.id;
            selectedNameModel?.val = option.name;
          },
          child: Container(
            constraints: BoxConstraints(
              minHeight: ITEM_HEIGHT - 1,
              maxHeight: ITEM_HEIGHT - 1,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TranslatedText(
                    option.name,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Radio<int>(
                  activeColor: theme(context).accentColor,
                  value: option.id,
                  onChanged: (selected) {
                    selectedModel.val = option.id;
                    selectedNameModel?.val = option.name;
                  },
                  groupValue: selectedModel.val,
                  visualDensity: VisualDensity.compact,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
