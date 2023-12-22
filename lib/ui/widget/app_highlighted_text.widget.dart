import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppHighlightedText extends StatefulWidget {
  final String text;
  final String highlightSubstring;
  final TextStyle? style;
  final TextAlign? textAlign;

  AppHighlightedText({
    required this.text,
    required this.highlightSubstring,
    this.style,
    this.textAlign,
  });

  @override
  _AppHighlightedTextState createState() => _AppHighlightedTextState();
}

class _AppHighlightedTextState extends State<AppHighlightedText> {
  final indices = <int>[];

  TextStyle? _defaultStyle;
  TextStyle? _highlightedStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultStyle = widget.style ?? Theme.of(context).textTheme.bodyText1;
    _highlightedStyle = _defaultStyle?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme(context).accentColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _updateIndices();
  }

  @override
  void didUpdateWidget(AppHighlightedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndices();
  }

  void _updateIndices() {
    indices.clear();

    if (widget.highlightSubstring.isEmpty) {
      return;
    }

    final text = widget.text.toLowerCase();
    final query = widget.highlightSubstring.toLowerCase();

    int index = 0;
    do {
      index = text.indexOf(query, index);
      if (index >= 0) {
        indices.add(index);
        index += query.length;
      } else {
        break;
      }
    } while (index >= 0);
  }

  @override
  Widget build(BuildContext context) {
    final children = <InlineSpan>[];
    int currentIndex = 0;

    for (int index in indices) {
      if (currentIndex < index) {
        children.add(TextSpan(
          text: widget.text.substring(currentIndex, index),
        ));
      }

      children.add(TextSpan(
        text: widget.text.substring(index, index + widget.highlightSubstring.length),
        style: _highlightedStyle,
      ));

      currentIndex = index + widget.highlightSubstring.length;
    }

    if (currentIndex < widget.text.length) {
      children.add(TextSpan(
        text: widget.text.substring(currentIndex),
      ));
    }

    return RichText(
      textAlign: widget.textAlign ?? TextAlign.start,
      text: TextSpan(
        style: _defaultStyle,
        children: children,
      ),
    );
  }
}
