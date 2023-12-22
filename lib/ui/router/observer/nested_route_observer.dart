import 'package:appkit/ui/router/observer/app_route_observer.dart';
import 'package:appkit/ui/router/observer/app_tab_route_observer.dart';
import 'package:appkit/ui/router/observer/route_observer.mixin.dart';

/// A nested [AppRouteObserver] that is intended to be used nested under [AppTabRouteObserver],
/// so that [RouteObserverMixin] can retrieve the correct instance of [AppRouteObserver].
class NestedRouteObserver extends AppRouteObserver {}
