import 'package:flutter/material.dart';

/// Changes [appBarElevation] to [maxElevation] when [scrollController] is scrolled down,
/// and resets it to 0 when it is scrolled all the way to the top.
mixin DynamicAppBarElevationMixin<T extends StatefulWidget> on State<T> {
  final scrollController = ScrollController();

  double maxElevation = 4;
  double _elevation = 0;

  double get appBarElevation => _elevation;

  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels > 0 && _elevation == 0) {
        setState(() {
          _elevation = maxElevation;
        });
      } else if (scrollController.position.pixels <= 0 && _elevation > 0) {
        setState(() {
          _elevation = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
