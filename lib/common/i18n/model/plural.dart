/// Defines a pluralized string.
class Plural {
  final String single;
  final String few;
  final String many;

  const Plural({
    required this.single,
    String? few,
    String? many,
  })  : this.few = few ?? single,
        this.many = many ?? few ?? single;

  String getString(String langKey, int count) {
    switch (langKey) {
      case 'ru':
        return _russian(count);
      default:
        return _kazakh(count);
    }
  }

  String _russian(int count) {
    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;

    if (lastDigit == 0 || lastDigit > 4 || (lastTwoDigits > 10 && lastTwoDigits < 15)) {
      return many;
    } else if (lastDigit > 1 && lastDigit < 5 && (lastTwoDigits < 10 || lastTwoDigits > 20)) {
      return few;
    } else if (lastDigit == 1 && lastTwoDigits != 11) {
      return single;
    } else {
      return many;
    }
  }

  String _kazakh(int count) {
    return single;
  }
}
