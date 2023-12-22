import 'package:appkit/ui/base/base.controller.dart';

class ListModel<T> {
  final List<T> _list;
  final BaseController? _controller;

  final _listeners = <void Function(List<T> list)>[];

  ListModel({
    List<T>? initialList,
    BaseController? controller,
  })  : _list = initialList ?? [],
        _controller = controller;

  List<T> get list => _list;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;

  T? get lastOrNull => _list.isNotEmpty ? _list.last : null;

  void add(T item) {
    _list.add(item);
    _onUpdate();
  }

  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    _onUpdate();
  }

  bool remove(T item) {
    int oldLength = _list.length;
    final didRemove = _list.remove(item);
    if (oldLength != _list.length) {
      _onUpdate();
    }
    return didRemove;
  }

  void removeWhere(bool Function(T item) predicate) {
    int oldLength = _list.length;
    _list.removeWhere(predicate);
    if (oldLength != _list.length) {
      _onUpdate();
    }
  }

  T removeAt(int index) {
    if (index >= 0 && index < _list.length) {
      final removedItem = _list.removeAt(index);
      _onUpdate();
      return removedItem;
    }
    throw Exception("Index $index is out of bounds: [0, ${_list.length}]");
  }

  void clear() {
    if (_list.isNotEmpty) {
      _list.clear();
      _onUpdate();
    }
  }

  void replaceAll(Iterable<T> items) {
    _list.replaceRange(0, _list.length, items);
    _onUpdate();
  }

  void updateItem(T item, void Function(T item) update) {
    update(item);
    _onUpdate();
  }

  void markUpdated() {
    _onUpdate();
  }

  void _onUpdate() {
    _listeners.forEach((listener) => listener(_list));
    _controller?.notifyListeners();
  }

  void addListener(void Function(List<T>) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function(List<T>) listener) {
    _listeners.remove(listener);
  }

  void removeAllListener() {
    _listeners.clear();
  }
}
