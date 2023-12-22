import 'package:flutter/material.dart';

import 'custom_theme_data.dart';

abstract class ThemeProvider {
  CustomThemeData getTheme(Brightness brightness);
}
