/// An option to be used in select-like lists, where one or more of multiple
/// options can be selected.
abstract class SelectOption {
  int get id;

  String get name;
}

/// Simple implementation of SelectOption for cases when a class is not available already.
class SimpleSelectOption implements SelectOption {
  final int id;
  final String name;

  const SimpleSelectOption(int? id, String? name)
      : this.id = id ?? -1,
        this.name = name ?? '';

  const SimpleSelectOption.label(this.name) : id = -1;
}
