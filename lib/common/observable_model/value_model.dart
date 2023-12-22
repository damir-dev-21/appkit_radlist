import 'dart:async';

import 'package:appkit/common/validation/validators.dart';
import 'package:appkit/ui/base/base.controller.dart';

class ValueModel<T> {
  final T? _initialVal;
  final String? fieldName;
  final BaseController? _controller;

  /// Regular listeners
  final _listeners = <void Function(T? val)>[];

  /// Listeners triggered only on non-silent updates.
  final _silentListeners = <void Function(T? val)>[];

  T? get initialVal => _initialVal;

  T? get val => _val;

  T get requireVal {
    if (val != null) {
      return val!;
    }
    throw Exception("Value model has no value");
  }

  T? _val;

  set val(T? newVal) {
    if (_val != newVal) {
      _val = newVal;
      _validationError = null;
      _controller?.notifyListeners();
      _listeners.forEach((listener) => listener(newVal));
      _silentListeners.forEach((listener) => listener(newVal));
    }
  }

  List<dynamic> get validators => _validators;
  late List<Validator<T?>> _validators;

  ValidationResult? get validationError => _validationError;
  ValidationResult? _validationError;

  set validationError(ValidationResult? error) {
    if (error != null) _validationError = error;
  }

  bool get hasError => _validationError != null;

  ValueModel({
    T? initialVal,
    this.fieldName,
    BaseController? controller,
    List<Validator<T?>>? validators,
  })  : _initialVal = initialVal,
        _controller = controller {
    _val = initialVal;

    if (validators != null) {
      _validators = validators;
    } else {
      _validators = [
        (T? value, String? fieldName) {
          return null;
        }
      ];
    }
  }

  /// Set the value if it has changed, and call only regular listeners
  /// (skipping non-silent listeners).
  void setValSilently(T newVal) {
    if (_val != newVal) {
      _val = newVal;
      _validationError = null;
      _controller?.notifyListeners();
      _listeners.forEach((listener) => listener(newVal));
    }
  }

  void reset() {
    val = _initialVal;
  }

  void addListener(void Function(T? val) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function(T? val) listener) {
    _listeners.remove(listener);
  }

  void addSilentListener(void Function(T? val) listener) {
    _silentListeners.add(listener);
  }

  void removeSilentListener(void Function(T? val) listener) {
    _silentListeners.remove(listener);
  }

  void removeAllRegularListeners() {
    _listeners.clear();
  }

  void removeAllSilentListeners() {
    _silentListeners.clear();
  }

  void addValidators(List<Validator<T?>> validators) {
    _validators.addAll(validators);
  }

  StreamSubscription bindToStream(Stream<T> stream) {
    return stream.listen((data) => val = data);
  }

  static void resetValidation(List<ValueModel> models) {
    models.forEach((model) => model.clearValidationError());
  }

  static bool validateAll(List<ValueModel> models) {
    var allValid = true;
    models.forEach((model) {
      if (allValid) {
        allValid = model.validate();
      } else {
        model.validate();
      }
    });
    return allValid;
  }

  static bool someEmpty(List<ValueModel> models) {
    return !notEmptyAll(models);
  }

  static bool notEmptyAll(List<ValueModel> models) {
    var allFilled = true;
    models.forEach((model) {
      if (allFilled) {
        if (model.isRequired() == true) {
          allFilled = Validators.required(model.val) == null;
        }
      }
    });
    return allFilled;
  }

  bool isRequired() {
    return validators.contains(Validators.required);
  }

  void clearValidationError() {
    _validationError = null;
    _controller?.notifyListeners();
  }

  bool validate() {
    ValidationResult? validationError;
    for (int i = 0; i < _validators.length; i++) {
      if (validationError != null) {
        break;
      }
      validationError = _validators[i](_val, fieldName ?? '');
    }

    _validationError = validationError;
    _controller?.notifyListeners();

    return _validationError == null;
  }

  @override
  String toString() {
    return 'LiveData{_val: $_val, _initialVal: $_initialVal, fieldName: $fieldName, _validationError: $_validationError}';
  }
}
