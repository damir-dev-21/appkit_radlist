import 'package:flutter/material.dart';

class CustomThemeData {
  final ThemeMode mode;
  final ThemeData themeData;
  final ThemeData? baseThemeWithCopy;

  /// The color of the navigation bar on Android and the navigation strip on iOS.
  final Color navigationBarColor;

  /// Default background color.
  Color get backgroundColor => themeData.backgroundColor;

  /// The accent color of the Material theme.
  Color get accentColor => themeData.colorScheme.secondary;

  /// Icon color that contrasts with the accent color.
  Color? get accentForegroundColor => themeData.colorScheme.onSecondary;

  /// The background color of foreground surfaces (such as cards and other UI elements
  /// that should contrast with the background color).
  Color get surfaceColor => themeData.cardColor;

  /// Default text style (useful for styling RichText widgets because for some reason
  /// they do not apply the Material theme by default).
  TextStyle? get bodyTextStyle => themeData.textTheme.bodyLarge;

  /// Default text color.
  Color? get textColor => themeData.textTheme.bodyLarge?.color;

  /// Foreground color for inverse backgrounds.
  final Color inverseTextColor;

  /// Hint color (lower contrast with background color compared to default text color).
  Color get hintColor => themeData.hintColor;

  /// Foreground hint color for inverse backgrounds.
  final Color inverseHintColor;

  /// Ripple color for inverse backgrounds.
  final Color inverseRippleColor;

  /// Ripple color for accent backgrounds.
  final Color accentRippleColor;

  /// Color for labels (such as input labels).
  final Color labelColor;

  /// The color of labels, when focused, such as when an input is focused.
  final Color focusedLabelColor;

  /// The default shadow color.
  final Color shadowColor;

  /// Color of dividers (and sometimes borders).
  Color get dividerColor => themeData.dividerColor;

  /// Yellowish warning color.
  final Color warningColor;

  /// Greenish success color.
  final Color successColor;

  /// Reddish error color.
  Color get errorColor => themeData.errorColor;

  /// Color for disabled controls.
  Color get disabledColor => themeData.disabledColor;

  /// Alternative text color.
  final Color altTextColor;
  final Color disabledTextColor;

  /// Default icon color.
  Color? get iconColor => themeData.iconTheme.color;

  /// Theme's brightness
  Brightness get brightness => themeData.brightness;

  /// Inverse of theme's brightness
  Brightness get inverseBrightness =>
      themeData.brightness == Brightness.light ? Brightness.dark : Brightness.light;

  final double radius;
  final double smallRadius;

  final BorderRadius borderRadius;
  final BorderRadius smallBorderRadius;

  final double? bodyText1FontSize;
  final double? bodyText2FontSize;

  CustomThemeData({
    required ThemeData baseTheme,
    this.baseThemeWithCopy,
    required this.mode,
    // Main
    required this.navigationBarColor,
    required backgroundColor,
    required Color surfaceColor,
    // Text colors
    required Color textColor,
    required this.inverseTextColor,
    required this.altTextColor,
    required this.disabledTextColor,
    required this.labelColor,
    required this.focusedLabelColor,
    required Color hintColor,
    required this.inverseHintColor,
    // Semantic colors
    required Color accentColor,
    required Brightness accentColorBrightness,
    required this.warningColor,
    required this.successColor,
    required Color errorColor,
    required Color disabledColor,
    // Component colors
    required Color iconColor,
    required Color dividerColor,
    // Misc
    required Color splashColor,
    required Color highlightColor,
    required this.accentRippleColor,
    required this.inverseRippleColor,
    required this.shadowColor,
    required this.radius,
    required this.smallRadius,
    required AppBarTheme appBarTheme,
    this.bodyText1FontSize,
    this.bodyText2FontSize,
  })  : borderRadius = BorderRadius.circular(radius),
        smallBorderRadius = BorderRadius.circular(smallRadius),
        themeData = baseThemeWithCopy ??
            baseTheme.copyWith(
              appBarTheme: appBarTheme,
              textTheme: baseTheme.textTheme.copyWith(
                bodyText1: baseTheme.textTheme.bodyText1?.copyWith(
                  color: textColor,
                  fontSize: bodyText1FontSize,
                ),
                bodyText2: baseTheme.textTheme.bodyText2?.copyWith(
                  color: textColor,
                  fontSize: bodyText2FontSize,
                ),
              ),
              inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
                fillColor: surfaceColor,
              ),
              iconTheme: baseTheme.iconTheme.copyWith(color: iconColor),
              floatingActionButtonTheme: baseTheme.floatingActionButtonTheme.copyWith(
                backgroundColor: accentColor,
                splashColor: accentRippleColor,
              ),
              buttonTheme: baseTheme.buttonTheme.copyWith(
                highlightColor: accentRippleColor,
                splashColor: accentRippleColor,
              ),
              backgroundColor: backgroundColor,
              scaffoldBackgroundColor: backgroundColor,
              colorScheme: ThemeData().colorScheme.copyWith(secondary: accentColor),
              brightness: accentColorBrightness,
              errorColor: errorColor,
              disabledColor: disabledColor,
              hintColor: hintColor,
              cardColor: surfaceColor,
              dividerColor: dividerColor,
              splashColor: splashColor,
              highlightColor: highlightColor,
              tabBarTheme: baseTheme.tabBarTheme.copyWith(
                labelColor: textColor,
                unselectedLabelColor: disabledTextColor,
                indicator: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 2, color: accentColor)),
                ),
              ),
            );
}
