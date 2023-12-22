import 'model/screen_breakpoints.dart';

class ResponsiveConfig {
  static ResponsiveConfig _instance = ResponsiveConfig._();

  static ResponsiveConfig get instance {
    return _instance;
  }

  ResponsiveConfig._();

  ScreenBreakpoints get breakpoints => _customBreakpoints ?? _defaultBreakPoints;

  static const ScreenBreakpoints _defaultBreakPoints = ScreenBreakpoints(
    desktop: 950,
    tablet: 800,
    smallTablet: 650,
  );

  ScreenBreakpoints? _customBreakpoints;

  void setCustomBreakpoints(ScreenBreakpoints breakpoints) {
    _customBreakpoints = breakpoints;
  }
}
