import 'dart:async';

import 'package:rxdart/rxdart.dart';

class DebouncedFunction<T> {
  final void Function(T param) fn;
  final Duration duration;
  final bool emitInitialValue;

  final _subject = PublishSubject<T>();
  late StreamSubscription _subscription;

  DebouncedFunction(this.fn, {required this.duration, this.emitInitialValue = false}) {
    _subscription = _subject.debounceTime(duration).listen(fn);
  }

  DateTime? _lastOfferTime;

  void call(T value) {
    if (emitInitialValue) {
      final now = DateTime.now();
      final lastOfferTime = _lastOfferTime;
      if (lastOfferTime == null || now.difference(lastOfferTime) > duration) {
        _lastOfferTime = now;
        fn(value);
        return;
      }

      _lastOfferTime = now;
    }

    _subject.add(value);
  }

  void dispose() {
    _subject.close();
    _subscription.cancel();
  }
}
