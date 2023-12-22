import 'dart:async';

import 'package:appkit/common/util/logger.dart';
import 'package:rxdart/rxdart.dart';

/// Sent out when all app caches should be cleared, such as when the user signs out
/// or the provider ID changes after switching the role.
class CleanupEvent {}

final _logger = Logger('EventBus');

class EventBus {
  // ignore: close_sinks
  final _bus = PublishSubject();

  void send<T>(T event) {
    _logger.log('Sending event $event');
    _bus.add(event);
  }

  StreamSubscription onEvent<T>(void Function() handler) {
    return _bus.whereType<T>().listen((_) {
      handler();
    });
  }

  StreamSubscription handleEvent<T>(void Function(T event) handler) {
    return _bus.whereType<T>().listen(handler);
  }

  static final EventBus instance = EventBus._();

  EventBus._();
}
