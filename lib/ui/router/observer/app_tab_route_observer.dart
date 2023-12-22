import 'app_route_observer.dart';

abstract class TabObserver {
  /// Function called when this tab is selected (either during initialization or
  /// when the user switches the tab to this one).
  void onTabSelected() {}

  /// Function called when another tab is selected.
  void onTabDeselected() {}
}

/// Adds additional methods specific to screens nested in other screens, such
/// as when a bottom navigation is used.
class AppTabRouteObserver extends AppRouteObserver {
  final _tabObservers = <TabObserver>[];

  void onTabSelected() {
    _tabObservers.forEach((it) => it.onTabSelected());
  }

  void onTabDeselected() {
    _tabObservers.forEach((it) => it.onTabDeselected());
  }

  void addTabObserver(TabObserver observer) {
    _tabObservers.add(observer);
  }

  void removeTabObserver(TabObserver observer) {
    _tabObservers.remove(observer);
  }
}
