import 'package:appkit/ui/base/base.controller.dart';

typedef void _ChangeListener(int previousLength);

/// An observable map with keys of type [K] and values of type [V].
/// When the map is modified, the provided controller is notified.
class MapModel<K, V> {
  final BaseController? _controller;
  final _changeListeners = <_ChangeListener>[];

  final _map = <K, V>{};

  MapModel({
    BaseController? controller,
  }) : _controller = controller;

  void addListener(_ChangeListener listener) {
    _changeListeners.add(listener);
  }

  void removeListener(_ChangeListener listener) {
    _changeListeners.remove(listener);
  }

  void removeAllListeners() {
    _changeListeners.clear();
  }

  V? operator [](K key) => _map[key];

  void operator []=(K key, V value) {
    if (_map[key] != value) {
      final oldLength = _map.length;
      _map[key] = value;
      _notifyListeners(oldLength);
    }
  }

  void remove(K key) {
    if (_map.containsKey(key)) {
      final oldLength = _map.length;
      _map.remove(key);
      _notifyListeners(oldLength);
    }
  }

  void clear() {
    if (_map.isNotEmpty) {
      final oldLength = _map.length;
      _map.clear();
      _notifyListeners(oldLength);
    }
  }

  void _notifyListeners(int oldLength) {
    _changeListeners.forEach((listener) => listener(oldLength));
    _controller?.notifyListeners();
  }

  Iterable<K> get keys => _map.keys;

  Iterable<V> get values => _map.values;

  bool containsKey(K key) => _map.containsKey(key);

  bool get isNotEmpty => _map.isNotEmpty;

  bool get isEmpty => _map.isEmpty;

  int get length => _map.length;
}
