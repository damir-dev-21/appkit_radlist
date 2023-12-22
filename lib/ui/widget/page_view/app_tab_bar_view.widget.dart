import 'package:flutter/material.dart';

/// Displays a [TabBarView] and calls [onTabChanged] when the tab is
/// scrolled past the midpoint between two tabs.
class AppTabBarView<T> extends StatefulWidget {
  final List<T>? tabs;
  final TabController? tabController;
  final List<Widget> children;
  final void Function(T tab)? onTabChanged;

  const AppTabBarView({
    Key? key,
    required this.children,
    this.tabs,
    this.tabController,
    this.onTabChanged,
  })  : assert((tabs != null) == (onTabChanged != null),
            'Must provide both tabs and onTabChanged, or none'),
        super(key: key);

  @override
  _AppTabBarViewState<T> createState() => _AppTabBarViewState<T>();
}

class _AppTabBarViewState<T> extends State<AppTabBarView<T>> {
  int _previousTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabBarView = TabBarView(
      controller: widget.tabController,
      children: widget.children,
    );
    final onTabChanged = widget.onTabChanged;
    final tabs = widget.tabs;
    if (onTabChanged != null && tabs != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.axis == Axis.horizontal) {
            // The scroll extent of a single tab.
            final tabScrollExtent = metrics.maxScrollExtent / tabs.length;
            final tabIndex = (metrics.pixels / (tabScrollExtent + 1)).floor();
            if (tabIndex != _previousTabIndex) {
              _previousTabIndex = tabIndex;
              onTabChanged(tabs[tabIndex]);
            }
          }

          return false;
        },
        child: tabBarView,
      );
    } else {
      return tabBarView;
    }
  }
}
