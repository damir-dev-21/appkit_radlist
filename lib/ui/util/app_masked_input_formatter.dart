import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Same as [MaskTextInputFormatter], but has the ability to reinitialize itself,
/// which is needed when clearing the input.
class AppMaskedInputFormatter extends TextInputFormatter {
  final String mask;
  final Map<String, RegExp>? filter;

  late MaskTextInputFormatter _formatter;
  AppMaskedInputFormatter({required this.mask, this.filter}) {
    reinitialize();
  }

  void reinitialize() {
    _formatter = MaskTextInputFormatter(mask: mask, filter: filter);
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return _formatter.formatEditUpdate(oldValue, newValue);
  }

  String getUnmaskedText() => _formatter.getUnmaskedText();
}
