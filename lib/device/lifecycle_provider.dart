import 'package:flutter/cupertino.dart';

abstract class LifecycleListener {
  void didChangeLifecycleState(AppLifecycleState state);
}

/// Proxies lifecycle state changes to listeners.
class LifecycleProxy implements LifecycleListener {
  final _listeners = <LifecycleListener>[];

  void addListener(LifecycleListener listener) {
    _listeners.add(listener);
  }

  void removeListener(LifecycleListener listener) {
    _listeners.remove(listener);
  }

  @override
  void didChangeLifecycleState(AppLifecycleState state) {
    _listeners.forEach((listener) => listener.didChangeLifecycleState(state));
  }
}
