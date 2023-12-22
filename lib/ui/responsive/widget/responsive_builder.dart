import 'package:appkit/appkit.dart';
import 'package:appkit/ui/responsive/model/device_screen_type.dart';
import 'package:flutter/material.dart';

import 'sizing_information_builder.widget.dart';

/// Provides a builder function for different screen types.
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  ResponsiveBuilder({
    Key? key,
    required this.phone,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizingInformationBuilder(builder: (context, sizingInformation) {
      EDeviceScreenType deviceType;
      final preferredScreenTypeGetter = Appkit.preferredScreenTypeGetter;
      if (preferredScreenTypeGetter != null) {
        deviceType = preferredScreenTypeGetter(context);
      } else {
        deviceType = sizingInformation.deviceScreenType;
      }
      switch (deviceType) {
        case EDeviceScreenType.desktop:
          return desktop?.call(context) ?? tablet?.call(context) ?? phone(context);
        case EDeviceScreenType.tablet:
          return tablet?.call(context) ?? phone(context);
        default:
          return phone(context);
      }
    });
  }
}
