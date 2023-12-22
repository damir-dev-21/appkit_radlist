final _snakeCasePattern = RegExp(r'_(\w)');

extension StringExtensions on String {
  /// Return a new string where this string is repeated [times] times.
  String repeat(int times) {
    final buffer = StringBuffer();
    for (int i = 0; i < times; i++) {
      buffer.write(this);
    }
    return buffer.toString();
  }

  /// Return the substring after the last occurrence of '/'.
  String basename() {
    final indexOfLastSeparator = lastIndexOf('/');
    if (indexOfLastSeparator >= 0) {
      return substring(indexOfLastSeparator + 1);
    }
    return this;
  }

  /// Convert the first character to upper case, and return the new string.
  String capitalize() {
    if (isNotEmpty) {
      if (length > 1) {
        return this[0].toUpperCase() + substring(1);
      } else {
        return this[0].toUpperCase();
      }
    } else {
      return this;
    }
  }

  /// Return null if this string is empty, otherwise return this string
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Return true if this string and [other] contains chars at given indices and
  /// the substrings [start, end) are equal. This is more efficient than comparing using
  /// [String.substring]
  bool equalsToIndexed(String other, int start, int end) {
    if (end < start) {
      return false;
    }

    if (start == end) {
      return true;
    }

    if (start < length && end < length && start < other.length && end < other.length) {
      for (int i = start; i < end; i++) {
        if (this[i] != other[i]) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  String snakeCaseToCamelCase() {
    return replaceAllMapped(_snakeCasePattern, (match) => match.group(1)?.toUpperCase() ?? this);
  }
}
