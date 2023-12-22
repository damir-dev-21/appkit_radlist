import 'package:flutter/widgets.dart';

import 'translation_provider.dart';

class TranslatedText extends StatelessWidget {
  final String translationKey;

  /// Used to split keys if [translationKey] contains multiple keys
  final String? delimiter;
  final String? suffix;
  final TextStyle? style;
  final bool uppercase;
  final TextAlign? textAlign;
  final int? count;
  final List<Object>? values;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    this.delimiter,
    this.suffix,
    this.style,
    this.uppercase = false,
    this.count,
    this.values,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  String _translate(BuildContext context, String text) {
    final count = this.count;
    if (count != null) {
      return translatePlural(context: context, key: text, count: count);
    } else {
      return translate(context, text, values: values);
    }
  }

  String _handleSuffix(String text) {
    final suffix = this.suffix;
    if (suffix != null) {
      return text + suffix;
    }
    return text;
  }

  String _handleUppercase(String text) {
    if (uppercase) {
      return text.toUpperCase();
    }
    return text;
  }

  List<String> _handleDelimiter(String text) {
    final delimiter = this.delimiter;
    if (delimiter != null) {
      return text.split(delimiter);
    }
    return [text];
  }

  @override
  Widget build(BuildContext context) {
    String text = '';
    List<String> translationKeyList = _handleDelimiter(translationKey);
    translationKeyList.asMap().forEach((index, key) {
      String translatedTextPart = _translate(context, key);
      translatedTextPart = _handleSuffix(translatedTextPart);
      translatedTextPart = _handleUppercase(translatedTextPart);
      final delimiter = this.delimiter;
      if (index != 0 && delimiter != null) {
        text += delimiter;
      }
      text += translatedTextPart;
    });

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
