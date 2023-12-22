import 'package:flutter/material.dart';

import 'device_screen_type.dart';

class SizingInformation {
  final EDeviceScreenType deviceScreenType;
  final Size screenSize;
  final Size localWidgetSize;

  SizingInformation({
    required this.deviceScreenType,
    required this.screenSize,
    required this.localWidgetSize,
  });

  @override
  String toString() {
    return 'SizingInformation{deviceScreenType: $deviceScreenType, '
        'screenSize: $screenSize, '
        'localWidgetSize: $localWidgetSize}';
  }
}
