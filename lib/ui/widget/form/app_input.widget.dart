import 'dart:math';

import 'package:appkit/common/extension/string.extensions.dart';
import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/common/util/format.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/util/app_masked_input_formatter.dart';
import 'package:appkit/ui/util/suffixed_number_formatter.dart';
import 'package:appkit/ui/util/ui_functions.dart';
import 'package:appkit/ui/widget/animation/app_shake_animation.widget.dart';
import 'package:appkit/ui/widget/app_icon.widget.dart';
import 'package:appkit/ui/widget/app_loading_indicator.dart';
import 'package:appkit/ui/widget/misc/ios_keyboard_dismiss_wrapper.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EAppInputSize { normal, small }

enum EAppInputTheme { normal, bordered, underlined }

// TODO: it was decided that clear button will makes money input empty
// final _emptyMoneyInputText = Format.amount(0);

// FIXME: AppInput custom design?

class AppInput extends StatefulWidget {
  /// Input label.
  final String? label;

  /// Placeholder string rendered inside the input.
  final String? placeholder;

  /// The input type (keyboard type, such as [TextInputType.number] for numeric).
  final TextInputType? inputType;

  /// TextField's textCapitalization property.
  final TextCapitalization? textCapitalization;

  /// The icon to be rendered at the beginning of the input.
  final IconData? prefixIcon;

  /// Custom icon from assets to be rendered at the beginning of the input.
  final String? prefixIconName;

  final double? prefixLeftPadding;

  /// The icon to be rendered at the end of the input.
  final Widget? suffixWidget;

  /// Additional hint widget to be rendered below the input.
  final Widget? hintWidget;

  /// If true, then the input is focused automatically on first render.
  final bool autofocus;

  /// If true, render as disabled and do not allow input.
  final bool disabled;

  /// If true, then mark the field as required.
  final bool showRequired;

  /// If true, then a clear button will be rendered after the input (unless [suffixWidget] is specified),
  /// which will clear the input value.
  final bool clearable;

  /// If true, then a loading indicator will be shown instead of the suffix widget.
  final bool isLoading;

  /// If true, then the value is obscured.
  final bool isPassword;

  /// If true, then the input is formatted using [SuffixedNumberFormatter.moneyFormatter]
  final bool isMoneyInput;

  /// The focus node for this input.
  final FocusNode? focusNode;

  /// The next focus node. If not null, then the textInputAction will be set to
  /// [TextInputAction.next] by default, unless [textInputAction] is provided.
  final FocusNode? nextFocus;

  /// The value of the input.
  final ValueModel<String> model;

  /// Size of the widget.
  final EAppInputSize size;

  /// The font size of the input.
  final double? fontSize;

  /// Widget appearance.
  final EAppInputTheme theme;

  /// Action button type to be used in the native keyboard.
  final TextInputAction? textInputAction;

  /// Maximum number of symbols allowed.
  final int? maxLength;

  /// Number of lines
  final int? lines;

  /// The formatter to be used on the input.
  final TextInputFormatter? formatter;

  /// Override default input decoration.
  final InputDecoration? customInputDecoration;

  /// Text alignment within the input.
  final TextAlign textAlign;

  /// Override text style within the input.
  final TextStyle? style;

  /// Override default padding around the widget.
  final EdgeInsets padding;

  /// Override default padding inside the widget.
  final EdgeInsets contentPadding;

  final Widget? tooltipWidget;

  /// Function to be called when the field is submitted by clicking on the text input action.
  /// on the soft keyboard.
  final void Function()? onTextInputActionPressed;

  /// Function to replace default input onTap behavior
  final VoidCallback? onTap;

  final bool alwaysShowLabel;

  final BorderRadius? borderRadius;

  final double? elevation;

  final Color? textColor;

  AppInput({
    Key? key,
    required this.model,
    this.label,
    this.placeholder,
    TextInputType? inputType,
    this.textCapitalization,
    this.prefixIcon,
    this.prefixIconName,
    this.prefixLeftPadding,
    this.suffixWidget,
    this.hintWidget,
    this.autofocus = false,
    this.disabled = false,
    this.showRequired = false,
    this.clearable = true,
    this.isLoading = false,
    this.isPassword = false,
    this.isMoneyInput = false,
    this.focusNode,
    this.nextFocus,
    this.size = EAppInputSize.normal,
    this.fontSize,
    this.theme = EAppInputTheme.underlined,
    this.textInputAction,
    this.maxLength,
    this.lines = 1,
    this.onTextInputActionPressed,
    this.formatter,
    this.customInputDecoration,
    this.textAlign = TextAlign.start,
    this.style,
    this.padding = EdgeInsets.zero,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.tooltipWidget,
    this.onTap,
    this.alwaysShowLabel = false,
    this.borderRadius,
    this.elevation,
    this.textColor,
  })  : inputType = isMoneyInput ? TextInputType.numberWithOptions(decimal: true) : inputType,
        super(key: key);

  @override
  _AppInputState createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  final _textFieldKey = GlobalKey();
  final _controller = TextEditingController();
  final _phoneNumberFormatter = AppMaskedInputFormatter(mask: '+7 (###) ###-##-##');
  late SuffixedNumberFormatter _moneyFormatter;
  late SuffixedNumberFormatter _numberFormatter;

  late FocusNode _focusNode;

  bool _obscureText = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();

    _setControllerText(widget.model.val ?? '');
    final text = widget.model.val;
    if (text != null && text.isNotEmpty == true) {
      if (_isPhoneInput) {
        _setControllerValue(_phoneNumberFormatter.formatEditUpdate(
          TextEditingValue(text: ''),
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        ));
      } else if (widget.isMoneyInput) {
        // Place cursor before the currency symbol
        _setControllerValue(TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length - 2),
        ));
      } else {
        _setControllerText(text);
      }
    } else {
      _setControllerText('');
    }

    if (widget.formatter == null && widget.isMoneyInput) {
      _moneyFormatter = SuffixedNumberFormatter.moneyFormatter();
    }
    if (_isNumberInput) {
      _numberFormatter = SuffixedNumberFormatter(suffix: null);
    }

    _controller.addListener(_onTextChange);
    _focusNode.addListener(_onFocusChange);
    widget.model.addListener(_onModelUpdated);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    widget.model.removeListener(_onModelUpdated);
    super.dispose();
  }

  void _onModelUpdated(String? value) {
    TextEditingValue textEditingValue;
    value ??= '';
    if (_isPhoneInput) {
      if (value.isEmpty == true) {
        value = '7';
      }

      final formatted = Format.phoneNumberPartial(value);
      textEditingValue = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      int offset;
      final oldValue = _controller.value;
      final oldOffset = oldValue.selection.start;
      if (oldOffset >= 0 &&
          oldOffset < value.length &&
          oldValue.text.equalsToIndexed(value, 0, oldOffset)) {
        offset = oldOffset;
      } else if (widget.isMoneyInput) {
        // Place cursor before the currency symbol.
        offset = value.length - 2;
      } else {
        offset = value.length;
      }

      textEditingValue = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: max(0, offset)),
      );
    }

    if (_controller.text != textEditingValue.text) {
      _setControllerValue(textEditingValue);
    }
  }

  bool _hasError() {
    return widget.model.validationError != null;
  }

  bool get _isPhoneInput {
    return widget.inputType == TextInputType.phone;
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
      if (_hasFocus) {
        widget.model.clearValidationError();
      }
      if (_controller.text.isEmpty && _isPhoneInput) {
        _resetPhoneInput();
      }
    });
  }

  void _onTextChange() {
    final value = _controller.text;
    if (_isPhoneInput) {
      if (value.isEmpty) {
        _resetPhoneInput();
      }
      _setModelValue('7' + _phoneNumberFormatter.getUnmaskedText());
    } else {
      _setModelValue(value);
    }
    setState(() {});
  }

  void _setModelValue(String value) {
    widget.model.val = value;
  }

  void _resetInput() {
    if (_isPhoneInput) {
      _resetPhoneInput();
    } else if (widget.isMoneyInput) {
      _resetMoneyInput();
    } else {
      _controller.clear();
    }
  }

  void _resetPhoneInput() {
    _phoneNumberFormatter.reinitialize();
    _setControllerValue(TextEditingValue(
      text: '+7 ',
      selection: TextSelection.collapsed(offset: 3),
    ));
  }

  void _resetMoneyInput() {
    _setControllerValue(TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 1),
    ));
  }

  void _setControllerValue(TextEditingValue value) {
    _controller.value = value;
  }

  void _setControllerText(String text) {
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildLabel(),
          AppShakeAnimation(
            child: _buildInput(),
            animate: _hasError(),
          ),
          if (widget.hintWidget != null) _buildHelpWidget(),
        ],
      ),
    );
  }

  Color? get _labelColor {
    if (_hasError()) {
      return theme(context).errorColor;
    } else if (_hasFocus) {
      return theme(context).textColor;
    } else {
      return theme(context).textColor;
    }
  }

  Widget _buildLabel() {
    String? label;
    final validationError = widget.model.validationError;
    if (validationError != null) {
      label = translate(context, validationError.message, values: validationError.formatValues);
    } else {
      if (widget.model.val?.isNotEmpty == true || widget.alwaysShowLabel) {
        label = widget.label ?? widget.model.fieldName;
        if (label != null) {
          label = translate(context, label);
        }
      }
    }

    if (label == null) return SizedBox.shrink();

    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: _labelColor,
              fontSize: 14.0,
            ),
            overflow: TextOverflow.clip,
          ),
        ),
        if (widget.tooltipWidget != null)
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: widget.tooltipWidget,
          ),
      ],
    );
  }

  Color? get _backgroundColor {
    if (_hasError()) {
      return theme(context).errorColor;
    } else if (widget.disabled) {
      return theme(context).disabledColor;
    } else {
      switch (widget.theme) {
        case EAppInputTheme.normal:
        default:
          return theme(context).surfaceColor;
      }
    }
  }

  Color? get _shadowColor {
    if (widget.theme == EAppInputTheme.bordered || widget.theme == EAppInputTheme.underlined) {
      return Colors.transparent;
    } else {
      return _hasFocus ? theme(context).shadowColor : Colors.transparent;
    }
  }

  Color? get _placeholderColor {
    return _hasError() ? theme(context).inverseTextColor.withAlpha(180) : theme(context).hintColor;
  }

  Color? get _textColor {
    return widget.textColor ??
        (_hasError()
            ? theme(context).inverseTextColor
            : widget.disabled
                ? theme(context).disabledTextColor
                : null);
  }

  Color get _borderColor {
    return widget.theme == EAppInputTheme.bordered
        ? theme(context).navigationBarColor
        : Colors.transparent;
  }

  Color get _focusedBorderColor {
    return widget.theme == EAppInputTheme.bordered
        ? theme(context).dividerColor
        : Colors.transparent;
  }

  List<TextInputFormatter>? get _inputFormatters {
    List<TextInputFormatter> formatters = [];
    if (_isPhoneInput) {
      formatters.add(_phoneNumberFormatter);
    }
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    final formatter = widget.formatter;
    if (formatter != null) {
      formatters.add(formatter);
    } else if (widget.isMoneyInput) {
      formatters.add(_moneyFormatter);
    } else if (_isFractionInput) {
      formatters.add(_numberFormatter);
    } else if (_isNumberInput) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return formatters.isNotEmpty ? formatters : null;
  }

  bool get _isNumberInput {
    return widget.inputType != null &&
        widget.inputType?.index == TextInputType.values.indexOf(TextInputType.number);
  }

  bool get _isFractionInput {
    return _isNumberInput && widget.inputType?.decimal == true;
  }

  TextInputAction get _textInputAction =>
      widget.textInputAction ??
      (widget.nextFocus != null ? TextInputAction.next : TextInputAction.done);

  Widget _buildInput() {
    return Material(
      elevation: widget.elevation ?? (_hasFocus ? 15 : 8),
      color: _backgroundColor,
      shadowColor: _shadowColor,
      borderRadius: widget.borderRadius ?? theme(context).smallBorderRadius,
      child: IosKeyboardDismissWrapper(
        focusNode: _focusNode,
        child: _buildTextField(),
        enabled: _isNumberInput || _isPhoneInput || _textInputAction != TextInputAction.done,
      ),
    );
  }

  Widget _buildTextField() {
    final prefixWidget = _buildPrefixWidget();
    final suffixWidget = _buildSuffixWidget();

    double leftPadding = widget.contentPadding.left;
    double rightPadding = widget.contentPadding.right;
    double topPadding = widget.contentPadding.top;
    double bottomPadding = widget.contentPadding.bottom;
    if (prefixWidget != null) {
      leftPadding += 15;
    }

    if (suffixWidget != null) {
      rightPadding += 48;
    }
    // Balance out with padding.
    if (widget.textAlign == TextAlign.center) {
      if (prefixWidget != null && suffixWidget == null) {
        rightPadding = 48;
      } else if (prefixWidget == null && suffixWidget != null) {
        leftPadding = 48;
      }
    }
    final textField = SizedBox(
      height: widget.inputType != TextInputType.multiline ? 32 : null,
      child: TextField(
        onTap: widget.onTap,
        key: _textFieldKey,
        autofocus: widget.autofocus,
        inputFormatters: _inputFormatters,
        enabled: !widget.disabled,
        focusNode: _focusNode,
        textInputAction: _textInputAction,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        readOnly: widget.onTap != null,
        onSubmitted: (_) {
          widget.onTextInputActionPressed?.call();

          nextFrame(() {
            if (widget.nextFocus != null) {
              FocusScope.of(context).unfocus();
              FocusScope.of(context).requestFocus(widget.nextFocus);
            } else if (widget.textInputAction == TextInputAction.next) {
              FocusScope.of(context).nextFocus();
            }
          });
        },
        scrollPadding:
            widget.hintWidget != null ? const EdgeInsets.all(70) : const EdgeInsets.all(20),
        keyboardType: widget.inputType,
        controller: _controller,
        obscureText: _obscureText,
        style: widget.style?.copyWith(color: _textColor) ??
            TextStyle(
              fontSize: widget.fontSize ?? (widget.size == EAppInputSize.normal ? 16 : 14),
              color: _textColor,
              height: 1.5,
            ),
        minLines: widget.lines,
        maxLines: widget.lines,
        textAlign: widget.textAlign,
        decoration: _buildInputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
            leftPadding,
            topPadding,
            rightPadding,
            bottomPadding,
          ),
        ),
      ),
    );

    if (suffixWidget != null || prefixWidget != null) {
      return Stack(
        children: <Widget>[
          textField,
          if (prefixWidget != null)
            Positioned(
              left: widget.prefixLeftPadding ?? 0,
              top: 0,
              bottom: 0,
              child: Center(child: prefixWidget),
            ),
          if (suffixWidget != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: widget.theme == EAppInputTheme.underlined ? -10 : 4,
              child: Center(child: suffixWidget),
            ),
        ],
      );
    } else {
      return textField;
    }
  }

  InputDecoration _buildInputDecoration({
    required EdgeInsets contentPadding,
  }) {
    final isRequired = widget.showRequired && widget.model.isRequired() == true;
    String placeholder = '';
    if (widget.placeholder != null) {
      placeholder = translate(
        context,
        '${widget.placeholder} ${isRequired ? "*" : ""}',
      );
    }
    final customInputDecoration = widget.customInputDecoration;
    if (customInputDecoration != null) {
      return customInputDecoration;
    } else if (widget.theme == EAppInputTheme.underlined) {
      final themeData = theme(context);
      final defaultBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: themeData.dividerColor),
      );

      return InputDecoration(
        isDense: true,
        errorStyle: TextStyle(color: themeData.errorColor),
        errorBorder: defaultBorder,
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: themeData.disabledColor),
        ),
        filled: false,
        contentPadding: contentPadding,
        hintText: placeholder,
        hintStyle: TextStyle(color: _placeholderColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: defaultBorder,
        focusedBorder: defaultBorder,
        enabledBorder: defaultBorder,
      );
    } else {
      final themeData = theme(context);
      final borderRadius = widget.borderRadius ?? themeData.smallBorderRadius;
      return InputDecoration(
        errorStyle: TextStyle(color: themeData.errorColor),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.transparent, width: 0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.transparent, width: 0),
        ),
        filled: false,
        contentPadding: contentPadding,
        hintText: placeholder,
        hintStyle: TextStyle(color: _placeholderColor),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: _focusedBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: _borderColor),
        ),
      );
    }
  }

  Widget? _buildPrefixWidget() {
    final prefixIcon = widget.prefixIcon;
    final prefixIconName = widget.prefixIconName;
    if (prefixIcon != null) {
      return Padding(
        padding: widget.size == EAppInputSize.normal
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Icon(
          prefixIcon,
          size: 22,
          color: _hasError()
              ? theme(context).inverseTextColor
              : _hasFocus
                  ? theme(context).accentColor
                  : theme(context).iconColor,
        ),
      );
    } else if (prefixIconName != null) {
      return Transform.translate(
        offset: const Offset(-6, 0),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AppIcon(
            prefixIconName,
            width: 15,
            height: 15,
            color: theme(context).iconColor,
          ),
        ),
      );
    } else {
      return null;
    }
  }

  Widget? _buildSuffixWidget() {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(right: 13),
        child: AppLoadingIndicator(size: 22),
      );
    } else if (widget.isPassword) {
      return IconButton(
        iconSize: 20,
        icon: AppIcon(
          _obscureText ? 'ic_eye' : 'ic_eye_slash',
          color: theme(context).textColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.clearable) {
      if (_controller.text.isNotEmpty &&
          (!_isPhoneInput || _controller.text.length > 3) &&
          (!widget.isMoneyInput || _controller.text != '')) {
        return IconButton(
          iconSize: 15,
          icon: Icon(
            Icons.cancel,
            color: _hasError() ? theme(context).inverseTextColor : theme(context).iconColor,
          ),
          onPressed: _controller.text.isNotEmpty
              ? () {
                  _resetInput();
                  if (_isPhoneInput) {
                    _phoneNumberFormatter.reinitialize();
                  }
                  _focusNode.requestFocus();
                }
              : null,
        );
      }
    }

    return widget.suffixWidget;
  }

  Widget _buildHelpWidget() {
    return Opacity(
      opacity: _controller.text.isEmpty ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: widget.hintWidget,
      ),
    );
  }
}
