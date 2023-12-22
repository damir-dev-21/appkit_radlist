import 'dart:async';

import 'package:appkit/common/util/logger.dart';
import 'package:appkit/data/operation_result.dart';
import 'package:appkit/ui/model/loading_state.dart';

import 'error_display.dart';

final _logger = Logger('Executor');

/// Runs asynchronous tasks.
abstract class Executor {
  static ErrorDisplay? _errorDisplay;

  static void setErrorDisplay(ErrorDisplay errorDisplay) {
    _errorDisplay = errorDisplay;
  }

  /// Run the asynchronous task defined by [request].
  /// [loadingState] is used to track the state of the task.
  /// [onResult] is called when the request completes successfully.
  /// [onError] is called when the request completes with an error.
  /// If [overrideErrorHandler] is supplied, then default error handling is NOT performed,
  ///   and instead the error gets passed to [overrideErrorHandler].
  /// [onComplete] gets called after the task completes regardless of the outcome.
  /// If [ignoreError] is true, then the default error handling is NOT performed.
  static Future<OperationResult<T?>> run<T>({
    required Future<OperationResult<T?>> request,
    LoadingState? loadingState,
    FutureOr<void> Function(T? result)? onResult,
    Function(dynamic error)? onError,
    Function(dynamic error)? overrideErrorHandler,
    Function()? onComplete,
    bool ignoreError = false,
  }) async {
    try {
      loadingState?.setLoading(true);

      final result = await request;
      if (result.isSuccessful) {
        await onResult?.call(result.value);
      } else if (result.isUnsuccessful) {
        onError?.call(result);
        if (overrideErrorHandler != null) {
          overrideErrorHandler(result);
        } else if (!ignoreError) {
          _errorDisplay?.showError(result);
        } else {
          _logger.log(result.toString());
        }
      }
      return result;
    } catch (error, stacktrace) {
      if (error is OperationCancelled) {
        return OperationError(errorMessage: 'Cancelled');
      }

      onError?.call(error);
      if (overrideErrorHandler != null) {
        overrideErrorHandler(error);
      } else if (!ignoreError) {
        _errorDisplay?.showError(error);
      }
      _logger.log('$error, $stacktrace');

      return OperationResult.fromError(error);
    } finally {
      loadingState?.setLoading(false);
      onComplete?.call();
    }
  }
}
