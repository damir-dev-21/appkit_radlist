import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:appkit/device/url_launcher.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final _linkRegExp = RegExp(r'<a>([^<]+)</a>');

/// Renders a translated text with a clickable link.
/// The translated text must have at most one link enclosed in <a> tags, like this:
///   "Visit <a>our website</a> for more information"
/// "our website" will be highlighted and be clickable.
class TranslatedLink extends StatelessWidget {
  /// The translation key or full link text.
  final String text;

  /// The URL that should be opened when the link is tapped.
  final String link;
  final TextStyle? style;
  final TextAlign textAlign;

  TranslatedLink({
    Key? key,
    required this.text,
    required this.link,
    this.style,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = theme(context);
    final style = this.style ?? themeData.bodyTextStyle ?? TextStyle();

    final translatedText = translate(context, text);
    final linkMatch = _linkRegExp.firstMatch(translatedText);

    if (linkMatch != null) {
      final parts = <TextSpan>[];
      if (linkMatch.start > 0) {
        parts.add(TextSpan(text: translatedText.substring(0, linkMatch.start)));
      }
      parts.add(
        TextSpan(
          text: linkMatch[1],
          style: style.copyWith(color: themeData.accentColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              UrlLauncher.launch(link);
            },
        ),
      );

      if (linkMatch.end < translatedText.length - 1) {
        parts.add(TextSpan(text: translatedText.substring(linkMatch.end)));
      }

      return RichText(
        text: TextSpan(style: style, children: parts),
        textAlign: textAlign,
      );
    } else {
      return Text(
        translatedText,
        style: style,
        textAlign: textAlign,
      );
    }
  }
}
