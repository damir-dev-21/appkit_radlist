import 'package:appkit/appkit.dart';
import 'package:appkit/ui/responsive/model/device_screen_type.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:flutter/material.dart';

/// Render widget returned by [builder] only if the current device is a phone.
class OnlyPhone extends StatelessWidget {
  final WidgetBuilder builder;

  OnlyPhone({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EDeviceScreenType deviceType;
    final preferredScreenTypeGetter = Appkit.preferredScreenTypeGetter;
    if (preferredScreenTypeGetter != null) {
      deviceType = preferredScreenTypeGetter(context);
    } else {
      deviceType = Responsive.deviceTypeFromContext(context);
    }
    if (deviceType == EDeviceScreenType.phone) {
      return builder(context);
    } else {
      return SizedBox.shrink();
    }
  }
}
