import 'package:appkit/common/i18n/translation_provider.dart';
import 'package:flutter/material.dart';

/// Subscribes to locale changes and calls [onLocaleChange] when the app locale (language)
/// changes.
mixin LocaleListenerMixin<T extends StatefulWidget> on State<T> {
  TranslationProvider? _translationProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationProvider = translations(context);
    _translationProvider?.addListener(onLocaleChange);
  }

  @override
  void dispose() {
    _translationProvider?.removeListener(onLocaleChange);
    _translationProvider = null;
    super.dispose();
  }

  /// Called when app language changes
  void onLocaleChange();
}
