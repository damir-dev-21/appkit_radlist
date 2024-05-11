import 'package:appkit/appkit.dart';
import 'package:appkit/common/i18n/translated_text.widget.dart';
import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/ui/responsive/model/device_screen_type.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

enum EButtonType {
  /// Transparent button without elevation or coloring.
  flat,

  /// Regular button.
  normal,

  /// Transparent button with a border.
  bordered,
}

enum EButtonSize { small, normal }

const _DEFAULT_PADDING = const EdgeInsets.symmetric(horizontal: 24);
const _DEFAULT_SMALL_PADDING = const EdgeInsets.symmetric(horizontal: 18);

class AppButton extends StatelessWidget {
  AppButton({
    Key? key,
    this.text,
    this.child,
    this.type = EButtonType.normal,
    this.size = EButtonSize.normal,
    this.padding,
    this.elevation = 0,
    this.disabled = false,
    this.onPressed,
    this.showLoader = false,
    this.progress,
    this.color,
    this.backgroundColor,
    this.height,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.fullWidth = false,
    this.autoSizeText = false,
    this.uppercase = false,
    this.borderRadius,
    this.borderColor,
  }) : super(key: key);

  /// The text to be rendered inside the button.
  final String? text;

  /// Custom content inside the button, overrides [text].
  final Widget? child;

  /// Button's type.
  final EButtonType type;

  /// Size of the button.
  final EButtonSize size;

  /// Override default padding.
  final EdgeInsets? padding;

  /// Add elevation.
  final double elevation;

  /// Whether the button should be disabled.
  final bool disabled;

  /// Whether a loading indicator should be shown on top of the button.
  final bool showLoader;

  /// If not null, then must be between 0.0 and 1.0 inclusive. If [showLoader] is true,
  /// then a [CircularProgressBar] will be shown instead of [AppLoadingIndicator] with the
  /// specified [progress] value.
  final double? progress;

  /// Custom text color.
  final Color? color;

  /// Custom background color.
  final Color? backgroundColor;

  /// Custom font size.
  final double? fontSize;

  /// Custom font weight.
  final FontWeight fontWeight;

  /// Custom button height.
  final double? height;

  /// If true, then the width of the button expands to fill available space.
  final bool fullWidth;

  /// If true, then [text] will be automatically sized to fit on one line.
  final bool autoSizeText;

  /// If true, then [text] will be converted to upper case.
  final bool uppercase;

  /// Function to be called when the button is pressed.
  final void Function()? onPressed;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  /// Custom border color.
  final Color? borderColor;

  double _getButtonHeight(BuildContext context) {
    final height = this.height;
    if (height != null) {
      return height;
    } else {
      final preferredScreenTypeGetter = Appkit.preferredScreenTypeGetter;
      EDeviceScreenType deviceType;
      if (preferredScreenTypeGetter != null) {
        deviceType = preferredScreenTypeGetter(context);
      } else {
        deviceType = Responsive.deviceTypeFromContext(context);
      }
      if (deviceType.isSmallerThan(EDeviceScreenType.tablet)) {
        return size == EButtonSize.normal ? 52 : 34;
      } else {
        return size == EButtonSize.normal ? 52 : 34;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getButtonHeight(context),
      child: _buildButton(context),
    );
  }

  Color? _getForegroundColor(BuildContext context) {
    final color = this.color;
    if (type == EButtonType.flat || type == EButtonType.bordered) {
      final normalColor = color ?? theme(context).accentColor;
      return disabled ? normalColor.withOpacity(0.5) : normalColor;
    } else if (color != null) {
      return color;
    } else {
      return theme(context).inverseTextColor;
    }
  }

  Color? _getBackgroundColor(BuildContext context) {
    return this.backgroundColor ??
        (type == EButtonType.normal
            ? theme(context).textColor
            : theme(context).surfaceColor);
  }

  Color? _getDisabledBackgroundColor(Color? bgColor) {
    return bgColor?.withOpacity(1);
  }

  Widget _buildButton(BuildContext context) {
    Widget button;
    final fgColor = _getForegroundColor(context);
    final fontSize = this.fontSize ?? (size == EButtonSize.small ? 15.0 : 16.0);
    if (type == EButtonType.normal || type == EButtonType.bordered) {
      button = _buildNormalButton(
        context: context,
        fgColor: fgColor ?? Colors.blueAccent,
        fontSize: fontSize,
      );
    } else {
      button = _buildFlatButton(
        context: context,
        fgColor: fgColor ?? Colors.blueAccent,
        fontSize: fontSize,
      );
    }

    return AbsorbPointer(
      absorbing: showLoader || disabled,
      child: button,
    );
  }

  Widget _buildNormalButton({
    required BuildContext context,
    required Color fgColor,
    required double fontSize,
  }) {
    final bgColor = _getBackgroundColor(context);
    final rippleColor = fgColor.withAlpha(50);

    return MaterialButton(
      visualDensity: VisualDensity.compact,
      padding: padding ??
          (size == EButtonSize.small
              ? _DEFAULT_SMALL_PADDING
              : _DEFAULT_PADDING),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: elevation,
      focusElevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      minWidth: 60,
      child:
          _buildContent(context: context, fgColor: fgColor, fontSize: fontSize),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(100),
        side: type == EButtonType.bordered
            ? BorderSide(
                color: borderColor ?? fgColor,
              )
            : BorderSide.none,
      ),
      onPressed: disabled == false ? onPressed : null,
      color: bgColor,
      disabledTextColor: type == EButtonType.bordered ? null : fgColor,
      disabledColor: showLoader
          ? bgColor
          : (type == EButtonType.bordered
              ? null
              : _getDisabledBackgroundColor(bgColor)),
      splashColor: rippleColor,
      highlightColor: rippleColor,
    );
  }

  Widget _buildFlatButton({
    required BuildContext context,
    required Color fgColor,
    required double fontSize,
  }) {
    return CupertinoButton(
      padding: padding ?? _DEFAULT_PADDING,
      child:
          _buildContent(context: context, fgColor: fgColor, fontSize: fontSize),
      onPressed: disabled == false ? onPressed : null,
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required Color fgColor,
    required double fontSize,
  }) {
    return Stack(
      children: [
        Visibility(
          visible: !showLoader,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: child ??
              _buildLabel(
                context,
                TextStyle(
                    color: fgColor, fontSize: fontSize, fontWeight: fontWeight),
              ),
        ),
        if (showLoader)
          Positioned.fill(
            child: Center(
              child: _buildLoadingIndicator(fgColor),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    if (progress != null) {
      return SizedBox(
        width: 23,
        height: 23,
        child: CircularProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
          strokeWidth: 3,
        ),
      );
    } else {
      return AppLoadingIndicator(color: color, size: 23);
    }
  }

  Widget _buildLabel(BuildContext context, TextStyle style) {
    if (autoSizeText) {
      final translatedText = translate(context, text ?? 'Не указан');
      return AutoSizeText(
        uppercase ? translatedText.toUpperCase() : translatedText,
        maxLines: 1,
        style: style,
      );
    } else {
      return TranslatedText(
        text ?? 'Не указан',
        style: style,
        uppercase: uppercase,
        textAlign: TextAlign.center,
      );
    }
  }
}
