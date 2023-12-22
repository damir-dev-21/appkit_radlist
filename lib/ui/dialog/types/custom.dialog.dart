import 'package:appkit/ui/dialog/common/app_dialog_wrapper.dart';
import 'package:appkit/ui/responsive/widget/responsive_builder.dart';
import 'package:appkit/ui/widget/app_divider.widget.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  late final _Config _config;

  CustomDialog(
      {Key? key,
      String? title,
      Widget? titleWidget,
      required Widget child,
      List<Widget>? topActions,
      List<Widget>? bottomActions,
      bool isCancelable = true,
      bool showCloseButton = true,
      VoidCallback? onClosePressed,
      EdgeInsets? insetPadding,
      double? tabletWidthFactor,
      double? tabletHeightFactor})
      : _config = _Config(
          title: title,
          titleWidget: titleWidget,
          child: child,
          topActions: topActions,
          bottomActions: bottomActions,
          isCancelable: isCancelable,
          showCloseButton: showCloseButton,
          onClosePressed: onClosePressed,
          insetPadding: insetPadding,
          heightFactor: tabletHeightFactor,
          widthFactor: tabletWidthFactor,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      phone: (_) => _CustomMobileDialog(config: _config),
      tablet: (_) => _CustomTabletDialog(config: _config),
    );
  }
}

class _Config {
  final String? title;
  final Widget? titleWidget;
  final Widget? child;
  final List<Widget>? topActions;
  final List<Widget>? bottomActions;
  final EdgeInsets? insetPadding;
  final bool? isCancelable;
  final bool? showCloseButton;
  final VoidCallback? onClosePressed;
  final double? widthFactor;
  final double? heightFactor;

  _Config({
    this.title,
    this.titleWidget,
    this.child,
    this.topActions,
    this.bottomActions,
    this.insetPadding,
    this.isCancelable,
    this.showCloseButton,
    this.onClosePressed,
    this.widthFactor,
    this.heightFactor,
  });

  void handleClosePressed(BuildContext context) {
    if (onClosePressed != null) {
      onClosePressed?.call();
    } else {
      Navigator.pop(context);
    }
  }
}

class _CustomMobileDialog extends StatelessWidget {
  final _Config config;

  _CustomMobileDialog({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppDialogWrapper(
      insetPadding: config.insetPadding,
      isCancelable: config.isCancelable,
      child: config.showCloseButton == true
          ? Stack(
              children: <Widget>[
                config.child ?? SizedBox.shrink(),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    key: ValueKey('customDialog.close'),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      config.handleClosePressed(context);
                    },
                  ),
                ),
              ],
            )
          : config.child,
    );
  }
}

class _CustomTabletDialog extends StatelessWidget {
  final _Config config;

  _CustomTabletDialog({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppDialogWrapper(
      insetPadding: EdgeInsets.zero,
      isCancelable: config.isCancelable,
      borderRadius: BorderRadius.zero,
      constrainWidth: false,
      child: FractionallySizedBox(
        widthFactor: config.widthFactor ?? 0.8,
        heightFactor: config.heightFactor ?? 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_needsTitle) _buildTitle(context),
            Expanded(
              child: config.child ?? SizedBox.shrink(),
            ),
            if (_hasActions) AppDivider(fullWidth: true),
            if (_hasActions) _buildActions(),
          ],
        ),
      ),
    );
  }

  bool get _needsTitle =>
      config.showCloseButton == true || config.title != null || config.titleWidget != null;

  bool get _hasActions => config.bottomActions?.isNotEmpty == true;

  Widget _buildTitle(BuildContext context) {
    Widget? titleWidget = config.titleWidget;
    if (titleWidget == null && config.title != null) {
      titleWidget = Text(
        config.title ?? '',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    }
    final topActions = config.topActions;
    return SizedBox(
      height: 74,
      width: double.infinity,
      child: Stack(
        children: [
          if (config.showCloseButton == true)
            Positioned(
              left: 12,
              top: 13,
              child: IconButton(
                icon: Icon(Icons.close),
                iconSize: 32,
                onPressed: () {
                  config.handleClosePressed(context);
                },
              ),
            ),
          if (titleWidget != null)
            Positioned(
              top: 16,
              bottom: 16,
              left: 72,
              right: 72,
              child: Center(
                child: titleWidget,
              ),
            ),
          if (topActions != null && topActions.isNotEmpty == true)
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: topActions,
              ),
            ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: AppDivider(
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final bottomActions = config.bottomActions;
    if (bottomActions != null && bottomActions.length > 1) {
      return Row(
        children: bottomActions
            .map(
              (widget) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: widget,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return FractionallySizedBox(
        widthFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: config.bottomActions?.first,
        ),
      );
    }
  }
}
