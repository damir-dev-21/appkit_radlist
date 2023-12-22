extension ListExtensions<T> on List<T> {
  /// Return the element at the specified index, or null.
  T? getOrNull(int index) => index < length ? this[index] : null;
}

extension IterableExtensions<T> on Iterable<T> {
  /// Return the first element if it exists, or null.
  T? get firstOrNull => isNotEmpty ? first : null;

  /// Return the last element if it exists, or null.
  T? get lastOrNull => isNotEmpty ? last : null;

  /// Same as [map], but returns a List instead of an Iterable, and the [mapper] takes an
  /// index as the second parameter.
  List<R> mapIndexed<R>(R Function(T item, int index) mapper) {
    final result = <R>[];
    int index = 0;
    forEach((element) {
      result.add(mapper(element, index));
      index++;
    });
    return result;
  }

  /// Return the element for which the field returned by [fieldGetter] has the largest value.
  T? maxBy<F extends num>(F Function(T item) fieldGetter) {
    T? max;
    for (T item in this) {
      if (max == null || fieldGetter(item) > fieldGetter(max)) {
        max = item;
      }
    }
    return max;
  }

  /// Associate the elements in this iterable by keys returned by the [keyFn].
  Map<K, T> associateBy<K>(K Function(T item) keyFn) {
    final result = <K, T>{};
    for (T item in this) {
      final key = keyFn(item);
      if (key != null) {
        result[key] = item;
      }
    }
    return result;
  }
}
