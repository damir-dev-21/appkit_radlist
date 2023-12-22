import 'package:appkit/appkit.dart';
import 'package:appkit/ui/router/app_router.dart';
import 'package:flutter/material.dart';

import 'model/device_screen_type.dart';
import 'responsive_config.dart';

abstract class Responsive {
  Responsive._();

  static bool _initialSizeSet = false;

  /// Initial size could be useful to scale unscaled things (e.g. overlay in AppTooltip)
  static Size? get initialSize => _initialSize;
  static Size? _initialSize;

  /// Get device type from the given screen [size].
  static EDeviceScreenType deviceTypeFromSize(Size size) {
    final deviceWidth = size.shortestSide;

    final breakpoints = ResponsiveConfig.instance.breakpoints;
    if (deviceWidth >= breakpoints.desktop) {
      return EDeviceScreenType.desktop;
    } else if (deviceWidth >= breakpoints.tablet) {
      return EDeviceScreenType.tablet;
    } else {
      return EDeviceScreenType.phone;
    }
  }

  /// Get device type using the given [context].
  static EDeviceScreenType deviceTypeFromContext(BuildContext context) {
    EDeviceScreenType deviceType;
    final preferredScreenTypeGetter = Appkit.preferredScreenTypeGetter;
    if (preferredScreenTypeGetter != null) {
      deviceType = preferredScreenTypeGetter(context);
    } else {
      deviceType = deviceTypeFromSize(MediaQuery.of(context).size);
    }
    return deviceType;
  }

  /// Return true if the current device type is phone.
  static bool isPhone(BuildContext context) {
    final EDeviceScreenType deviceType = deviceTypeFromContext(context);
    return deviceType == EDeviceScreenType.phone;
  }

  /// Return true if the current device type is tablet.
  static bool isTablet(BuildContext context) {
    final EDeviceScreenType deviceType = deviceTypeFromContext(context);
    return deviceType == EDeviceScreenType.tablet;
  }

  /// Return true if the current device type is tablet
  /// and it is small enough to trigger smaller UI rendering.
  static bool isSmallTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final breakpoints = ResponsiveConfig.instance.breakpoints;
    // Shortest side should be height, otherwise its in vertical orientation and is
    // considered as phone device
    return shortestSide == size.height && shortestSide <= breakpoints.smallTablet;
  }

  /// Executes given functions according to device type.
  static void executor({
    Function? phone,
    Function? tablet,
    Function? desktop,
  }) {
    final deviceType = Responsive.deviceTypeFromContext(AppRouter.currentContext);
    switch (deviceType) {
      case EDeviceScreenType.phone:
        phone?.call();
        break;
      case EDeviceScreenType.tablet:
        tablet?.call();
        break;
      case EDeviceScreenType.desktop:
        desktop?.call();
        break;
    }
  }

  /// Set [_initialSize]. It was intended to use this to store size
  /// from initial and unmodified [MediaQueryData].
  static void setInitialSize(Size size) {
    if (!_initialSizeSet) {
      _initialSize = size;
      _initialSizeSet = true;
    }
  }

  /// Scales given [factor] so that the height proportion remains
  /// the same when the keyboard shows up.
  static double scaleHeightFactor(double factor, [BuildContext? context]) {
    final mqData = MediaQuery.of(context ?? AppRouter.currentContext);
    final keyboardHeight = mqData.viewInsets.bottom;
    final height = mqData.size.height;
    return factor + ((1 - factor) * keyboardHeight / height);
  }
}
