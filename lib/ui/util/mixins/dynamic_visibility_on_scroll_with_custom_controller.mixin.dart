import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../ui_functions.dart';

/// Toggles the [dynamicVisibility] boolean flag when the user scrolls up or down.
/// The flag is set to true when the user scrolls up, and to false otherwise.
mixin DynamicVisibilityOnScrollWithCustomController<T extends StatefulWidget> on State<T> {
  ScrollController get scrollController;

  bool get dynamicVisibility => _isVisible;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    nextFrame(() {
      scrollController.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (scrollController.position.userScrollDirection == ScrollDirection.forward && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    } else if (scrollController.position.userScrollDirection == ScrollDirection.reverse &&
        _isVisible) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
