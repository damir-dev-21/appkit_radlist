import 'package:appkit/common/i18n/appkit_tr.dart';
import 'package:appkit/common/validation/validation_utils.dart';
import 'package:appkit/ui/util/suffixed_number_formatter.dart';

class ValidationResult {
  final String message;
  final List<Object>? formatValues;

  const ValidationResult(this.message, [this.formatValues]);
}

typedef ValidationResult? Validator<T>(T value, String fieldName);

abstract class Validators {
  // Validator functions
  static ValidationResult? required(dynamic val, [String fieldName = '']) {
    if (val == null || (val is String && val.isEmpty)) {
      return ValidationResult(AppkitTr.validation.required$);
    }
    return null;
  }

  static ValidationResult? mobilePhone(String? val, String fieldName) {
    final requiredMessage = Validators.required(val, fieldName);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (val != null && !ValidationUtils.isValidMobilePhone(val)) {
      return ValidationResult(AppkitTr.validation.phoneNumber$);
    }
    return null;
  }

  static ValidationResult? password(String? val, String fieldName) {
    if (val != null && val.length < 6) {
      return ValidationResult(AppkitTr.validation.passwordMin$, [6]);
    }
    if (val != null && val.length > 255) {
      return ValidationResult(AppkitTr.validation.passwordMax$, [255]);
    }
    return null;
  }

  static ValidationResult? bin(String? val, String fieldName) {
    if (val != null && val.isNotEmpty && !ValidationUtils.isValidBin(val)) {
      return ValidationResult(AppkitTr.validation.bin$);
    }
    return null;
  }

  static ValidationResult? email(String? val, String fieldName) {
    if (val != null && val.isNotEmpty && !ValidationUtils.isValidEmail(val)) {
      return ValidationResult(AppkitTr.validation.email$);
    }
    return null;
  }

  static ValidationResult? trueRequired(bool? val, String fieldName) {
    if (val != null && !val) {
      return ValidationResult(AppkitTr.validation.required$);
    }
    return null;
  }

  static ValidationResult? requiredAmount(dynamic val, String fieldName) {
    final requiredMessage = required(val, fieldName);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    double? numericValue;
    if (val is String) {
      numericValue = SuffixedNumberFormatter.parseNumber(val);
    } else if (val is double) {
      numericValue = val;
    } else {
      return ValidationResult(AppkitTr.validation.invalid$);
    }

    if (numericValue != null && numericValue < 0.01) {
      return ValidationResult(AppkitTr.validation.minValue$, ['0.01']);
    }
    return null;
  }

  static Validator minValue(double minValue, {String? errorMessage}) {
    return _constraint(
      constraint: minValue,
      isLowerBound: true,
      errorMessageFn: (value) => errorMessage != null
          ? ValidationResult(errorMessage)
          : ValidationResult(AppkitTr.validation.minValue$, [minValue]),
    );
  }

  static Validator maxValue(double maxValue, {String? errorMessage}) {
    return _constraint(
      constraint: maxValue,
      isLowerBound: false,
      errorMessageFn: (value) => errorMessage != null
          ? ValidationResult(errorMessage)
          : ValidationResult(AppkitTr.validation.maxValue$, [maxValue]),
    );
  }

  static Validator match(String anotherVal, String errorMessage) {
    return (dynamic val, String fieldName) {
      if (val == anotherVal) {
        return null;
      } else {
        return ValidationResult(errorMessage);
      }
    };
  }

  static Validator _constraint({
    required double constraint,
    required bool isLowerBound,
    required ValidationResult Function(String value) errorMessageFn,
  }) {
    return (dynamic val, String fieldName) {
      double? numericValue;
      if (val is String) {
        numericValue = SuffixedNumberFormatter.parseNegativeNumber(val);
      } else if (val is double) {
        numericValue = val;
      } else if (val != null) {
        return ValidationResult(AppkitTr.validation.invalid$);
      }

      final isConstraintViolated = (numericValue != null &&
          ((isLowerBound && numericValue < constraint) ||
              (!isLowerBound && numericValue > constraint)));

      if (isConstraintViolated) {
        final value = constraint.truncateToDouble() == constraint
            ? constraint.truncate().toString()
            : constraint.toStringAsFixed(2);

        return errorMessageFn(value);
      }
      return null;
    };
  }
}
