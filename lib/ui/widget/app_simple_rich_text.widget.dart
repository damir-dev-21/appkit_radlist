import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppSimpleRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  static final _boldPattern = RegExp(r'<b>([^<]+)</b>', multiLine: true);

  const AppSimpleRichText(
    this.text, {
    Key? key,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: theme(context).bodyTextStyle,
        children: _parseText(style),
      ),
    );
  }

  List<TextSpan> _parseText(TextStyle? baseStyle) {
    final result = <TextSpan>[];

    final boldMatches = _boldPattern.allMatches(text);
    final boldMatchesIterator = boldMatches.iterator;
    bool hasNext = boldMatchesIterator.moveNext();

    int i = 0;
    while (i < text.length) {
      final nextMatchStart = (hasNext ? boldMatchesIterator.current.start : null) ?? text.length;

      if (nextMatchStart == i) {
        result.add(TextSpan(
          text: boldMatchesIterator.current.group(1),
          style: baseStyle?.copyWith(fontWeight: FontWeight.w500),
        ));
        i = boldMatchesIterator.current.end;
        hasNext = boldMatchesIterator.moveNext();
      } else {
        result.add(TextSpan(text: text.substring(i, nextMatchStart), style: baseStyle));
        i = nextMatchStart;
      }
    }

    return result;
  }
}
