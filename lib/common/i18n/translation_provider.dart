import 'package:appkit/common/extension/list.extensions.dart';
import 'package:appkit/common/i18n/model/translation_spec.dart';
import 'package:appkit/data/storage/local_storage.dart';
import 'package:appkit/framework/di_utils.dart';
import 'package:flutter/widgets.dart';

import 'model/plural.dart';

/// Translate the given translation [key] and return either the translated value
/// or the key itself if no translation is found for the current language key.
///
/// [values] specifies a list of objects to be interpolated into the translated
/// string. Interpolation is performed into the placeholders in the form `{n}`,
/// where `n` identifies the index of the corresponding value from [values].
/// So, for example, a string "Hello {1}, how are {0} today?" with values
/// ["you", "John"], is going to be transformed into "Hello John, how are you today?"
String translate(BuildContext context, String key, {List<Object>? values}) {
  return provide<TranslationProvider>(context).get(key, values: values);
}

String translateOnce(BuildContext context, String key, {List<Object>? values}) {
  return provideOnce<TranslationProvider>(context).get(key, values: values);
}

/// Translate a plural translation [key] using the given [count]. [values] specifies
/// a list of objects to be interpolated into the translated string.
String translatePlural({
  required BuildContext context,
  required String key,
  required int count,
  List<Object>? values,
}) {
  return provide<TranslationProvider>(context).getPlural(key, count, values: values);
}

String translatePluralOnce({
  required BuildContext context,
  required String key,
  required int count,
  List<Object>? values,
}) {
  return provideOnce<TranslationProvider>(context).getPlural(key, count, values: values);
}

TranslationProvider translations(BuildContext context) => provideOnce<TranslationProvider>(context);

/// Keeps a mapping of translation keys for each language key, handles translation lookup.
class TranslationProvider with ChangeNotifier {
  static const _LS_KEY_LANG_KEY = 'kz.appkit.langKey';
  static const _DEFAULT_LANG_KEY = 'ru';

  final LocalStorage _localStorage;
  final List<TranslationSpec> _translationRegistry;

  final Map<String, Map<String, dynamic>> mappings = {
    _DEFAULT_LANG_KEY: {},
  };

  Map<String, dynamic>? get currentMapping => mappings[langKey];

  String get langKey => _langKey;
  String _langKey = _DEFAULT_LANG_KEY;

  String get fullLocale {
    switch (langKey) {
      case 'ru':
        return 'ru_RU';
      case 'kk':
        return 'kk_KZ';
      default:
        return 'ru_RU';
    }
  }

  TranslationProvider({
    required LocalStorage localStorage,
    required List<TranslationSpec> translationRegistry,
  })   : _localStorage = localStorage,
        _translationRegistry = translationRegistry {
    _init();
  }

  void _init() async {
    await _localStorage.init();
    final savedLangKey = _localStorage.getString(_LS_KEY_LANG_KEY);
    if (savedLangKey != null) {
      _langKey = savedLangKey;
      notifyListeners();
    }

    _initTranslationMappings();
  }

  void _initTranslationMappings() {
    if (mappings.isNotEmpty) {
      mappings.clear();
    }
    _translationRegistry.forEach((spec) => _addTranslations(null, spec.values));
  }

  /// Recursively add the given translations to the translation table.
  void _addTranslations(String? keyPrefix, Map<String, dynamic> translations) {
    translations.forEach((key, value) {
      if (value is String) {
        mappings[key] ??= {};
        if (keyPrefix != null) {
          mappings[key]?[keyPrefix] = value;
        }
      } else if (value is List) {
        mappings[key] ??= {};
        if (keyPrefix != null) {
          mappings[key]?[keyPrefix] = Plural(
            single: value.first,
            few: value.getOrNull(1),
            many: value.getOrNull(2),
          );
        }
      } else if (value is Map<String, dynamic>) {
        bool shouldComputeNewPrefix = true;
        if (keyPrefix != null) {
          final lastIndexOfDot = keyPrefix.lastIndexOf('.');
          String lastKey = keyPrefix;
          if (lastIndexOfDot >= 0) {
            lastKey = keyPrefix.substring(lastIndexOfDot);
          }
          if (lastKey == key) {
            shouldComputeNewPrefix = false;
            _addTranslations(keyPrefix, value);
          }
        }

        if (shouldComputeNewPrefix) {
          final newKeyPrefix = keyPrefix == null ? key : '$keyPrefix.$key';
          _addTranslations(newKeyPrefix, value);
        }
      } else {
        throw 'Invalid translation spec: expected either a map, a string, or a Plural'
            'but got ${value.runtimeType}: $value';
      }
    });
  }

  /// Get the translation value for [key].
  String get(String key, {List<Object>? values}) {
    final mapping = currentMapping?[key] ?? mappings[_DEFAULT_LANG_KEY]?[key];
    if (mapping != null && mapping is String) {
      if (values != null) {
        return _formatValues(mapping, values);
      }
      return mapping;
    }
    return key;
  }

  /// Get the plural translation value for [key] and [count].
  String getPlural(String key, int count, {List<Object>? values}) {
    final mapping = currentMapping?[key] ?? mappings[_DEFAULT_LANG_KEY]?[key];
    if (mapping != null && mapping is Plural) {
      final format = mapping.getString(langKey, count);
      if (values != null) {
        return _formatValues(format, values);
      } else {
        return format;
      }
    }
    return key;
  }

  static final _formatRegExp = RegExp(r'{(\d+)}');

  String _formatValues(String text, List<Object> values) {
    return text.replaceAllMapped(_formatRegExp, (match) {
      final str = match[1];
      if (str != null) {
        final digit = int.tryParse(str);
        if (digit != null && digit < values.length) {
          return values[digit].toString();
        }
      }
      return '';
    });
  }

  /// Set the current language key.
  void setLangKey(String langKey) {
    if (_langKey != langKey) {
      _langKey = langKey;
      _localStorage.putString(_LS_KEY_LANG_KEY, langKey);
      _initTranslationMappings();
      notifyListeners();
    }
  }
}
