enum EDeviceScreenType {
  phone,
  tablet,
  desktop,
}

extension EDeviceScreenTypeExtension on EDeviceScreenType {
  bool isSmallerThan(EDeviceScreenType other) {
    return index < other.index;
  }

  bool isLargerThan(EDeviceScreenType other) {
    return index > other.index;
  }
}
