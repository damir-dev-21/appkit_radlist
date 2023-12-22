import 'dart:math';

import 'package:appkit/app.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Scales child down in landscape orientation if device is small (see [Responsive.isSmallTablet]).
/// Most of the code is taken from [ResponsiveWrapper]
/// Note that this logic is handled AFTER [ResponsiveWrapper]'s logic in [App]'s [AppLifecycleWrapper]'s
/// build method. This way ensures that final app layout is reactive to orientation change.
class AppResponsiveTabletScaler extends StatelessWidget {
  final Widget child;

  static const double scalingFactor = 0.75;
  static const double inverseScalingFactor = 1 / scalingFactor;

  const AppResponsiveTabletScaler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Responsive.isSmallTablet(context)) {
      final mqData = MediaQuery.of(context);
      final scaledWidth = mqData.size.width * inverseScalingFactor;
      final scaledHeight = mqData.size.height * inverseScalingFactor;

      /// Source: responsive_wrapper library
      return MediaQuery(
        data: mqData.copyWith(
            size: Size(scaledWidth, scaledHeight),
            devicePixelRatio: mqData.devicePixelRatio * inverseScalingFactor,
            viewInsets: _getScaledViewInsets(mqData),
            viewPadding: _getScaledViewPadding(mqData),
            padding: _getScaledPadding(mqData)),
        child: SizedBox(
          width: mqData.size.width,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            child: Container(
              width: scaledWidth,
              height: scaledHeight,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      );
    } else {
      /// Do not modify child if tablet is large enough to display it properly
      return child;
    }
  }

  EdgeInsets _getScaledViewInsets(MediaQueryData data) {
    double leftInsetFactor;
    double topInsetFactor;
    double rightInsetFactor;
    double bottomInsetFactor;
    double scaledLeftInset;
    double scaledTopInset;
    double scaledRightInset;
    double scaledBottomInset;

    final screenWidth = data.size.width;
    final screenHeight = data.size.height;
    final scaledWidth = screenWidth * inverseScalingFactor;
    final scaledHeight = screenHeight * inverseScalingFactor;

    leftInsetFactor = data.viewInsets.left / screenWidth;
    topInsetFactor = data.viewInsets.top / screenHeight;
    rightInsetFactor = data.viewInsets.right / screenWidth;
    bottomInsetFactor = data.viewInsets.bottom / screenHeight;

    scaledLeftInset = leftInsetFactor * scaledWidth;
    scaledTopInset = topInsetFactor * scaledHeight;
    scaledRightInset = rightInsetFactor * scaledWidth;
    scaledBottomInset = bottomInsetFactor * scaledHeight;

    return EdgeInsets.fromLTRB(
        scaledLeftInset, scaledTopInset, scaledRightInset, scaledBottomInset);
  }

  EdgeInsets _getScaledViewPadding(MediaQueryData data) {
    double leftPaddingFactor;
    double topPaddingFactor;
    double rightPaddingFactor;
    double bottomPaddingFactor;
    double scaledLeftPadding;
    double scaledTopPadding;
    double scaledRightPadding;
    double scaledBottomPadding;

    final screenWidth = data.size.width;
    final screenHeight = data.size.height;
    final scaledWidth = screenWidth * inverseScalingFactor;
    final scaledHeight = screenHeight * inverseScalingFactor;

    leftPaddingFactor = data.viewPadding.left / screenWidth;
    topPaddingFactor = data.viewPadding.top / screenHeight;
    rightPaddingFactor = data.viewPadding.right / screenWidth;
    bottomPaddingFactor = data.viewPadding.bottom / screenHeight;

    scaledLeftPadding = leftPaddingFactor * scaledWidth;
    scaledTopPadding = topPaddingFactor * scaledHeight;
    scaledRightPadding = rightPaddingFactor * scaledWidth;
    scaledBottomPadding = bottomPaddingFactor * scaledHeight;

    return EdgeInsets.fromLTRB(
        scaledLeftPadding, scaledTopPadding, scaledRightPadding, scaledBottomPadding);
  }

  EdgeInsets _getScaledPadding(MediaQueryData data) {
    double scaledLeftPadding;
    double scaledTopPadding;
    double scaledRightPadding;
    double scaledBottomPadding;
    scaledLeftPadding =
        max(0.0, _getScaledViewPadding(data).left - _getScaledViewInsets(data).left);
    scaledTopPadding = max(0.0, _getScaledViewPadding(data).top - _getScaledViewInsets(data).top);
    scaledRightPadding =
        max(0.0, _getScaledViewPadding(data).right - _getScaledViewInsets(data).right);
    scaledBottomPadding =
        max(0.0, _getScaledViewPadding(data).bottom - _getScaledViewInsets(data).bottom);

    return EdgeInsets.fromLTRB(
        scaledLeftPadding, scaledTopPadding, scaledRightPadding, scaledBottomPadding);
  }
}
