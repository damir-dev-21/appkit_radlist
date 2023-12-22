/// Defines a translation mapping. Each key is a translation key, and a value
/// can either be another [TranslationSpec], or a Map where each key is a language key
/// and the value is the translated string.
abstract class TranslationSpec {
  Map<String, Map<String, dynamic>> get values;
}
