import 'dart:io';

import 'package:appkit/common/util/logger.dart';
import 'package:appkit/device/connection_state_provider.dart';

abstract class OperationResult<T> {
  final T? value;

  final String? errorTitle;
  final String? errorMessage;
  final int? statusCode;
  final int? errorCode;

  List<Object>? errorMessageValues;

  bool get isSuccessful => this is OperationSuccess;

  bool get isUnsuccessful => this is OperationError;

  bool get isCancelled => this is OperationCancelled;

  OperationResult({
    this.value,
    this.errorTitle,
    this.errorMessage,
    this.errorMessageValues,
    this.statusCode,
    this.errorCode,
  });

  OperationResult<R> map<R>(R Function(T? value) valueConverter, {String? errorMessage}) {
    if (isSuccessful) {
      return OperationSuccess(valueConverter(value));
    } else {
      return OperationError(
        errorTitle: errorTitle,
        errorMessage: errorMessage ?? this.errorMessage,
        errorMessageValues: errorMessageValues,
        statusCode: statusCode,
        errorCode: errorCode,
      );
    }
  }

  /// Same as [map], but the [valueConverter] returns a Future, and consequently the
  /// method itself returns a Future as well.
  Future<OperationResult<R>> asyncMap<R>(
    Future<R> Function(T? value) valueConverter, {
    String? errorMessage,
  }) {
    if (isSuccessful) {
      return valueConverter(value).then((converted) => OperationSuccess(converted));
    } else {
      return Future.value(OperationError(
        errorTitle: errorTitle,
        errorMessage: errorMessage ?? this.errorMessage,
        statusCode: statusCode,
      ));
    }
  }

  OperationResult<R?> mapError<R>({String? errorMessage}) {
    return map((_) => null, errorMessage: errorMessage);
  }

  static OperationResult<T> fromError<T>(dynamic error) {
    try {
      if (error is SocketException) {
        if (ConnectionStateProvider.instance?.currentConnectionState.isConnected == true) {
          return OperationError(
            errorMessage: 'Не удалось установить соединение с сервером',
          );
        } else {
          return OperationError(
            errorMessage: 'Отсутствует подключение к интернету',
          );
        }
      } else {
        return OperationError(errorMessage: error.message);
      }
    } on NoSuchMethodError catch (_) {
      return OperationError(errorMessage: 'Неизвестная ошибка: $error');
    }
  }
}

class OperationSuccess<T> extends OperationResult<T> {
  OperationSuccess(T? value) : super(value: value);

  @override
  String toString() {
    return '''OperationSuccess {
    value = $value
    }''';
  }
}

class OperationError<T> extends OperationResult<T> {
  OperationError({
    String? errorTitle,
    String? errorMessage,
    List<Object>? errorMessageValues,
    int? statusCode,
    int? errorCode,
  }) : super(
          errorTitle: errorTitle,
          errorMessage: errorMessage,
          errorMessageValues: errorMessageValues,
          statusCode: statusCode,
          errorCode: errorCode,
        ) {
    Log.d('Creating operation error with status $statusCode');
  }

  @override
  String toString() {
    return '''OperationError {
    errorTitle = $errorTitle,
    errorMessage = $errorMessage
    errorCode = $errorCode
    }''';
  }
}

class OperationCancelled<T> extends OperationResult<T> {
  OperationCancelled();

  String get message => 'Ваша сессия истекла. Пожалуйста, войдите заново.';
}
