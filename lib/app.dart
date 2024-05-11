import 'package:appkit/appkit.dart';
import 'package:appkit/common/util/app_error.dart';
import 'package:appkit/device/lifecycle_provider.dart';
import 'package:appkit/framework/di_utils.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:appkit/ui/responsive/widget/app_responsive_tablet_scaler.widget.dart';
import 'package:appkit/ui/router/app_router.dart';
import 'package:appkit/ui/router/observer/app_route_observer.dart';
import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class App extends StatelessWidget {
  final List<SingleChildStatelessWidget> providers;
  final ThemeProvider themeProvider;
  final WidgetBuilder rootScreenBuilder;
  final RouteFactory? onGenerateRoute;

  App({
    Key? key,
    required this.providers,
    required this.themeProvider,
    required this.rootScreenBuilder,
    this.onGenerateRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Appkit.isConfigured) {
      throw AppError('Appkit.configure must be called before runApp');
    }

    return MultiProvider(
      providers: providers,
      child: CustomThemeWrapper(
        themeProvider: themeProvider,
        builder: (context) => AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: theme(context).brightness,
            statusBarIconBrightness: theme(context).inverseBrightness,
            systemNavigationBarColor: theme(context).navigationBarColor,
            systemNavigationBarIconBrightness: theme(context).inverseBrightness,
            systemNavigationBarDividerColor: theme(context).navigationBarColor,
          ),
          child: AppLifecycleWrapper(
            rootScreenBuilder: rootScreenBuilder,
            onGenerateRoute: onGenerateRoute,
          ),
        ),
      ),
    );
  }
}

class AppLifecycleWrapper extends StatefulWidget {
  final WidgetBuilder rootScreenBuilder;
  final RouteFactory? onGenerateRoute;

  AppLifecycleWrapper({
    Key? key,
    required this.rootScreenBuilder,
    this.onGenerateRoute,
  }) : super(key: key);

  @override
  _AppLifecycleWrapperState createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  LifecycleProxy? _lifecycleProxy;
  final _routeObserver = AppRouteObserver(isRootObserver: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lifecycleProxy == null) {
      _lifecycleProxy = provideOnce(context);
    }

    _lifecycleProxy?.didChangeLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _routeObserver,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRouter.navigatorKey,
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: theme(context).themeData,
        // themeMode: theme(context).mode,
        themeMode: ThemeMode.light,
        supportedLocales: const [
          Locale('en'),
          // Locale('ru'),
        ],
        onGenerateRoute: widget.onGenerateRoute,
        navigatorObservers: [_routeObserver],
        home: widget.rootScreenBuilder(context),
      ),
    );
  }
}
