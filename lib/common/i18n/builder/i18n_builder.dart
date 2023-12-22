import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:yaml/yaml.dart';

Builder i18nBuilder(BuilderOptions options) => I18nBuilder(options);

const _SUPPORTED_LANGUAGES = ['ru', 'en'];

/// Generates two dart files for each .i18n.yaml file
///
/// 1) .i18n.keys.dart file contains the translation keys to be referenced from code
/// 2) .i18n.spec.dart file contains the actual translation specs to be consumed by
///    [TranslationProvider]
///
/// Make sure to register all TranslationSpecs and Key classes in translation_registry.dart
class I18nBuilder implements Builder {
  /// When running the build_runner script with --release flag, this field is true,
  /// and we generate more optimized code, which is less convenient for debugging.
  final bool isReleaseMode;

  I18nBuilder(BuilderOptions options) : isReleaseMode = (options.config['isReleaseMode'] ?? false) as bool;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (isReleaseMode) {
      print(
        '*===============================================================\n'
        '* RUNNING IN RELEASE MODE\n'
        '*===============================================================',
      );
    }

    final inputId = buildStep.inputId;

    final fileName = inputId.pathSegments.last;
    final objectName = fileName.substring(0, fileName.indexOf('.'));
    final contents = await buildStep.readAsString(inputId);
    final messages = loadYaml(contents) as YamlMap;

    final formatter = DartFormatter();
    final emitter = DartEmitter(allocator: Allocator());

    final translationKeys = Library(
      (b) => b.body.addAll(_generateKeyClasses(objectName, messages)),
    );
    await buildStep.writeAsString(
      inputId.changeExtension('.keys.dart'),
      formatter.format('${_generateHeaderComment(fileName)}${translationKeys.accept(emitter)}'),
    );

    final translationSpec = Library(
      (b) => b.body.add(_generateTranslationSpec(objectName, messages)),
    );
    await buildStep.writeAsString(
      inputId.changeExtension('.spec.dart'),
      formatter.format('${_generateHeaderComment(fileName)}${translationSpec.accept(emitter)}'),
    );
  }

  /// Recursively generate the key classes used to reference translation keys from code.
  ///
  /// [objectName] specifies the prefix for the root class.
  /// [messages] contains the mapping of translation keys to either translation values or nested
  /// messages.
  /// [keyPrefix] is the current key prefix, which gets more nested as the recursion gets deeper.
  List<Class> _generateKeyClasses(
    String objectName,
    YamlMap messages, {
    String? keyPrefix,
    bool private = false,
  }) {
    final result = <Class>[];
    result.insert(0, Class((b) {
      b.name = '${private ? '_' : ''}${objectName.asClassPrefix()}TranslationKeys';
      if (private) {
        b.constructors.add(Constructor((b) => b..constant = isReleaseMode));
      }

      messages.forEach((key, value) {
        if (value is YamlMap) {
          if (value.hasNestedSpec) {
            final nestedObjectName = key;

            if (value.hasTranslation) {
              // Generate a translation key field with a '$' suffix, because
              // the un-suffixed field will reference the nested object below.
              b.fields.add(_generateKeyField(
                fieldName: '$key\$',
                translationKey: _newKeyPrefix(keyPrefix, key),
                translationValue: value,
              ));
            }

            final nestedClasses = _generateKeyClasses(
              nestedObjectName,
              value,
              keyPrefix: _newKeyPrefix(keyPrefix, key),
              private: true,
            );

            // Reference to the nested translation key object.
            b.fields.add(
              Field(
                (b) => b
                  ..modifier = FieldModifier.final$
                  ..type = refer(nestedClasses.first.name)
                  ..name = nestedObjectName
                  ..assignment =
                      Code((isReleaseMode ? 'const ' : '') + nestedClasses.first.name + '()'),
              ),
            );

            result.addAll(nestedClasses);
          } else {
            b.fields.add(_generateKeyField(
              fieldName: key,
              translationKey: _newKeyPrefix(keyPrefix, key),
              translationValue: value,
            ));
          }
        }
      });
    }));
    return result;
  }

  /// Generate a translation key field with [fieldName] as the field name and [translationKey]
  /// as the assignment value.
  /// The [translationValue] will be used to generate a documentation
  /// string with the Russian translation as the content.
  Field _generateKeyField({
    required String fieldName,
    required String translationKey,
    required YamlMap translationValue,
  }) {
    final translatedValue = translationValue['ru'];

    return Field((b) => b
      ..modifier = FieldModifier.final$
      ..type = refer('String')
      ..name = fieldName
      ..docs.addAll([if (translatedValue != null) '/// ' + translatedValue.toString().trim()])
      ..assignment = Code("'$translationKey'"));
  }

  /// Generate a TranslationSpec class for the given [messages]. The [objectName] will
  /// be used as the prefix for the class name.
  Class _generateTranslationSpec(String objectName, YamlMap messages) {
    return Class((b) {
      b.name = '${objectName.asClassPrefix()}Translations';
      b.implements.add(
        refer('TranslationSpec', 'package:appkit/common/i18n/model/translation_spec.dart'),
      );
      b.constructors.add(Constructor((b) => b.constant = isReleaseMode));

      final values = <String, Map<String, dynamic>>{};
      _collectValues(messages, values);

      b.fields.add(
        Field((b) => b
          ..modifier = FieldModifier.final$
          ..type = refer('Map<String, Map<String, dynamic>>')
          ..name = 'values'
          ..annotations.add(refer('override'))
          ..assignment = isReleaseMode ? literalConstMap(values).code : literalMap(values).code),
      );
    });
  }

  /// Recursively collect translation values from [messages] into [translationValues].
  /// [keyPrefix] specifies the current key prefix, which gets more nested as the
  /// recursion gets deeper.
  void _collectValues(
    YamlMap messages,
    Map<String, Map<String, dynamic>> translationValues, {
    String? keyPrefix,
  }) {
    messages.forEach((key, value) {
      if (value is YamlMap) {
        final newKeyPrefix = _newKeyPrefix(keyPrefix, key);
        if (value.hasNestedSpec) {
          final translationMap = _processTranslationValue(value);
          if (translationMap.isNotEmpty) {
            translationValues[newKeyPrefix] = translationMap;
          }

          _collectValues(
            value,
            translationValues,
            keyPrefix: newKeyPrefix,
          );
        } else {
          translationValues[newKeyPrefix] = _processTranslationValue(value);
        }
      }
    });
  }

  Map<String, dynamic> _processTranslationValue(YamlMap translationValue) {
    return translationValue.map((key, value) {
      if (value is String) {
        return MapEntry(key, value.trim());
      } else if (value is YamlList) {
        return MapEntry(key, value.map((it) => it.trim()).toList());
      } else {
        return MapEntry(key, null);
      }
    })
      ..removeWhere((key, value) => value == null);
  }

  /// Create a nested key prefix.
  String _newKeyPrefix(String? keyPrefix, String key) {
    if (keyPrefix == null) {
      return key;
    } else {
      return '$keyPrefix.$key';
    }
  }

  String _generateHeaderComment(String sourceFileName) {
    final comment = '// GENERATED FILE. DO NOT EDIT\n'
        '// To modify translations, edit the $sourceFileName file\n\n';
    return isReleaseMode
        ? comment
        // Typed as 'FIX' + 'ME' to avoid detection by git pre-commit hook
        : '// ${'FIX' + 'ME'}: build i18n files in release mode, without the `watch` argument\n$comment';
  }

  @override
  final Map<String, List<String>> buildExtensions = {
    '.i18n.yaml': ['.i18n.keys.dart', '.i18n.spec.dart']
  };
}

extension _StringExtension on String {
  static final _snakeCasePattern = RegExp(r'_(\w)');

  /// Convert snake_case to PascalCase.
  String asClassPrefix() {
    return this[0].toUpperCase() +
        substring(1)
            .replaceAllMapped(_snakeCasePattern, (match) => match[1]?.toUpperCase() ?? this);
  }
}

extension _YamlMapExtension on YamlMap {
  /// True if this message map contains a nested message map
  bool get hasNestedSpec {
    return keys.any((key) => !_SUPPORTED_LANGUAGES.contains(key));
  }

  /// True if this message map contains translation values.
  bool get hasTranslation {
    return keys.any((key) => _SUPPORTED_LANGUAGES.contains(key));
  }
}
