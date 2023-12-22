import 'dart:async';

class ThrottledFunction<T, R> {
  final Future<R> Function(T? params) fn;
  final Duration duration;
  final bool emitInitialValue;

  T? _scheduledValue;
  Timer? _emissionTimer;
  Completer<R>? _resultCompleter;

  ThrottledFunction(
    this.fn, {
    required this.duration,
    this.emitInitialValue = false,
  });

  Future<R>? call(T value) {
    if (_resultCompleter == null) {
      _resultCompleter = Completer();
    }

    if (_emissionTimer == null) {
      _scheduledValue = value;
      _emissionTimer = Timer(duration, () async {
        final x = fn(_scheduledValue);
        _resultCompleter?.complete(x);
        _resultCompleter = null;
        _emissionTimer = null;
        _scheduledValue = null;
      });
    }

    return _resultCompleter?.future;
  }

  void dispose() {
    _emissionTimer?.cancel();
  }
}
