import 'debounced_function.dart';

class DebouncedRunnable {
  final _value = Object();
  final DebouncedFunction<Object> _debouncedFn;

  DebouncedRunnable(
    Function() fn, {
    required Duration duration,
    bool emitInitialValue = false,
  }) : _debouncedFn = DebouncedFunction(
          (_) => fn(),
          duration: duration,
          emitInitialValue: emitInitialValue,
        );

  void call() {
    _debouncedFn.call(_value);
  }

  void dispose() {
    _debouncedFn.dispose();
  }
}
