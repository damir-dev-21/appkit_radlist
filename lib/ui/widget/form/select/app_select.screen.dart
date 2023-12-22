import 'dart:math';

import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/dialog/app_dialog.dart';
import 'package:appkit/ui/model/select_option.dart';
import 'package:appkit/ui/pagination/model/paginator.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:appkit/ui/router/app_router.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/mixins/dynamic_appbar_elevation.mixin.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/app_back_button.widget.dart';
import 'package:appkit/ui/widget/app_button.widget.dart';
import 'package:appkit/ui/widget/app_scaffold.widget.dart';
import 'package:appkit/ui/widget/util/app_align_bottom.widget.dart';
import 'package:flutter/material.dart';

import 'app_list_select.widget.dart';
import 'app_select.dialog.dart';

/// A screen that lets the user select one option of several.
class AppSelectScreen<T extends SelectOption> extends StatefulWidget {
  /// The title string to be displayed in the appbar.
  final String title;

  /// List of options to select from.
  final List<T>? options;

  /// If the list of options is paginated with an async data source, provide [paginator]
  /// instead of [options].
  final Paginator<T>? paginator;

  /// The currently selected option's ID, can be null
  final int? selectedId;

  /// The currently selected option's name, can be null
  final String? selectedName;

  /// If true, then a clear button will be shown in the appbar.
  final bool showClearButton;

  /// If provided together with [showClearButton], then the clear button will be shown
  /// unless the current value equals to [defaultOption].
  final T? defaultOption;

  final String? additionalButtonTitle;
  final Widget? additionalButtonIcon;
  final VoidCallback? onAdditionalButtonPressed;

  final String? textForEmptyOptions;

  /// Text shown on the submit button.
  final String? submitButtonText;

  /// Open the select screen. Return the ID of the selected option, or null if the selection
  /// was cleared.
  /// If [useContextForNavigation] is true, then the provided [context] will be passed
  /// to [AppRouter] when opening the screen.
  static Future open<T extends SelectOption>({
    required String title,
    int? selectedId,
    String? selectedName,
    required BuildContext context,
    bool useContextForNavigation = true,
    List<T>? options,
    Paginator<T>? paginator,
    bool showClearButton = false,
    T? defaultOption,
    String? additionalButtonTitle,
    Widget? additionalButtonIcon,
    VoidCallback? onAdditionalButtonPressed,
    String? textForEmptyOptions,
    String? submitButtonText,
  }) {
    assert(options != null || paginator != null);

    if (Responsive.isPhone(context)) {
      return AppRouter.pushScreen(
        (_) => AppSelectScreen<T>(
          title: title,
          options: options,
          paginator: paginator,
          selectedId: selectedId,
          selectedName: selectedName,
          showClearButton: showClearButton,
          defaultOption: defaultOption,
          additionalButtonTitle: additionalButtonTitle,
          additionalButtonIcon: additionalButtonIcon,
          onAdditionalButtonPressed: onAdditionalButtonPressed,
          textForEmptyOptions: textForEmptyOptions,
          submitButtonText: submitButtonText,
        ),
        context: useContextForNavigation ? context : null,
      );
    } else {
      return AppDialog.showFullyCustom(
        (_) => AppSelectDialog<T>(
          selectedId: selectedId,
          selectedName: selectedName,
          title: title,
          options: options,
          paginator: paginator,
          showClearButton: showClearButton,
          additionalButtonTitle: additionalButtonTitle,
          onAdditionalButtonPressed: onAdditionalButtonPressed,
          textForEmptyOptions: textForEmptyOptions,
          defaultOption: defaultOption,
        ),
      );
    }
  }

  const AppSelectScreen({
    Key? key,
    required this.title,
    this.selectedId,
    this.showClearButton = false,
    this.selectedName,
    this.defaultOption,
    this.options,
    this.paginator,
    this.additionalButtonTitle,
    this.additionalButtonIcon,
    this.onAdditionalButtonPressed,
    this.textForEmptyOptions,
    this.submitButtonText,
  })  : assert(options != null || paginator != null),
        super(key: key);

  @override
  _AppSelectScreenState<T> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState<T extends SelectOption> extends State<AppSelectScreen<T>>
    with DynamicAppBarElevationMixin {
  final _model = ValueModel<int>();
  final _nameModel = ValueModel<String>();

  bool _isScrollPositionInitialized = false;

  @override
  void initState() {
    super.initState();
    _model.val = widget.selectedId;
    _model.addListener((val) {
      setState(() {});
    });
  }

  void _scrollToPosition(double listHeight) {
    final index = widget.options?.indexWhere((it) => it.id == widget.selectedId) ?? -1;
    if (index >= 0) {
      final position = index * 66.0;

      // -100 accounts for the height of the button that overlays the list.
      if (position > listHeight - 150) {
        scrollController.jumpTo(min(position, scrollController.position.maxScrollExtent));
      }
    }

    _isScrollPositionInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, SimpleSelectOption(widget.selectedId, widget.selectedName));
        return false;
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: AppBackButton(),
          title: TranslatedText(widget.title),
          elevation: appBarElevation,
          actions: widget.showClearButton && _model.val != widget.defaultOption?.id
              ? <Widget>[
                  AppButton(
                    text: AppkitTr.action.reset$,
                    type: EButtonType.flat,
                    size: EButtonSize.small,
                    onPressed: () {
                      Navigator.pop(context,
                          SimpleSelectOption(widget.defaultOption?.id, widget.defaultOption?.name));
                    },
                  ),
                ]
              : null,
        ),
        backgroundColor: theme(context).surfaceColor,
        body: Builder(
          builder: (context) {
            // Need to know the height of the available space so that
            // the list is not scrolled if the currently selected position
            // is less than that height.
            final renderObject = context.findRenderObject();

            if (!_isScrollPositionInitialized && renderObject != null) {
              final renderBox = renderObject as RenderBox;
              nextFrame(() {
                _scrollToPosition(renderBox.size.height);
              });
            } else {
              // The RenderBox should be available on next build.
              nextFrame(() {
                setState(() {});
              });
            }
            final paginator = widget.paginator;
            final options = widget.options;
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                paginator == null && (options == null || options.isEmpty)
                    ? _buildEmptyScreen(context)
                    : AppListSelect<T>(
                        controller: scrollController,
                        options: options,
                        paginator: paginator,
                        selectedModel: _model,
                        selectedNameModel: _nameModel,
                        padding: const EdgeInsets.only(bottom: 80),
                      ),
                AppAlignBottom(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: AppButton(
                            text: widget.submitButtonText ?? AppkitTr.action.apply$,
                            disabled: _model.val == null,
                            onPressed: () {
                              Navigator.pop(
                                  context, SimpleSelectOption(_model.val, _nameModel.val));
                            },
                          ),
                        ),
                        if (widget.onAdditionalButtonPressed != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: FloatingActionButton(
                              backgroundColor: theme(context).accentColor,
                              child: widget.additionalButtonIcon ?? Icon(Icons.add),
                              onPressed: widget.onAdditionalButtonPressed,
                              tooltip: widget.additionalButtonTitle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
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
