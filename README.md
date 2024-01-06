# appkit

Provides common boilerplate code for Flutter applications.

### Configure the library by calling `Appkit.configure` before executing `runApp`:

```dart
Appkit.configure(
  errorDisplay: AppErrorDisplay(),
  loadingWidgetBuilder: ({Widget child, bool isLoading}) => AppLoadingView(
    loading: isLoading,
    child: child,
  ),
  failedWidgetBuilder: ({VoidCallback onRetry}) => AppLoadFailed(onRetry: onRetry),
  emptyWidgetBuilder: () => AppEmptyView(),
);
```

---

### Call `runApp`:

```dart
runApp(App(
  themeProvider: const _ThemeProvider(),
  /// List of global singleton providers. This list must include
  providers: providers,
  /// Builder function for the first screen that is shown on app launch.
  rootScreenBuilder: (_) => RootScreen(),
  /// Optionally specify the MaterialApp's onGenerateRoute function
  onGenerateRoute: AppRouterConfig.generateRoute,
));

/// Return the configured CustomThemeData depending on Brightness
class _ThemeProvider implements ThemeProvider {

  const _ThemeProvider();

  @override
  CustomThemeData getTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return darkCustomTheme;
      case Brightness.light:
        return lightCustomTheme;
      default:
        return null;
    }
  }
}
```

The `providers` list passed to `App` constructor must include the `TranslationProvider`,
declared as follows:

```dart
ChangeNotifierProvider(
  create: (context) => TranslationProvider(
    localStorage: provideOnce(context),
    translationRegistry: TRANSLATION_REGISTRY,
  ),
),
```

where `TRANSLATION_REGISTRY` can be defined as:

```dart
import 'package:appkit/common/i18n/appkit.i18n.keys.dart';
import 'package:appkit/common/i18n/appkit.i18n.spec.dart';
import 'package:appkit/common/i18n/model/translation_spec.dart';

// ignore: non_constant_identifier_names
final TRANSLATION_REGISTRY = <TranslationSpec>[
  AppkitTranslations(),
];

class _AllKeys with AppkitTranslationKeys {}

// ignore: non_constant_identifier_names
final Tr = _AllKeys();
```

---

### Http

In order to make use of common HTTP request logic, extend the `BaseHttp` class:

```dart
class Http extends BaseHttp {
  static const HEADER_DEVICE_INFO = 'X-Device-Info';
  static const HEADER_REQUEST_ID = 'X-Request-ID';

  final LocalStorage _localStorage;
  final LifecycleProxy _lifecycleProxy;

  UpdateChecker get updateChecker => _updateChecker;
  UpdateChecker _updateChecker;

  Http({
    @required LocalStorage localStorage,
    @required LifecycleProxy lifecycleProxy,
  })  : _localStorage = localStorage,
        _lifecycleProxy = lifecycleProxy,
        super(HttpConfig(
          baseUrl: Config.baseUrl + '/api/v1',
          deviceInfoHeader: HEADER_DEVICE_INFO,
          requestIdHeader: HEADER_REQUEST_ID,
        ));

  // Example initialization
  @override
  void initialize() {
    _updateChecker = UpdateChecker(
      localStorage: _localStorage,
      http: this,
      lifecycleProxy: _lifecycleProxy,
    );
  }

  // Example interceptor configuration.
  Iterable<Interceptor> configureInterceptors() {
    return [
      UnauthenticatedInterceptor(),
      PaymentRequiredInterceptor(),
      UpdateCheckerInterceptor(updateChecker),
    ];
  }
}
```

---

### Notifications

Call `AndroidNotificationChannel.init()` when initializing notifications.

---

### Device info

`DeviceInfo.getBuildNumber()` assumes that android APKs are split by ABI
such that the APK for every ABI is generated with the same build number but
multiplied by a factor of `1 000 000`. This is to ensure that every ABI gets
its own build number (this is required by play market), and the build numbers
of the same version of the app built for different ABIs don't clash.

If your APKs are not split by ABI, the following is not needed.

In order to make this work, add the following block within the `android` section of
your `android/app/build.gradle` file:

```groovy
/// Split built APKs by ABI for release versions
splits {
    abi {
        enable gradle.startParameter.taskNames.contains("assembleProductionRelease") ||
                gradle.startParameter.taskNames.contains("assembleDevelopmentRelease")
        reset()
        include 'x86_64', 'armeabi-v7a', 'arm64-v8a'
    }
}
```

And below the `android` block:

```groovy
// Map for the version code that gives each ABI a value.
ext.abiCodes = ['armeabi-v7a': 1, x86: 2, x86_64: 3, 'arm64-v8a': 4]

import com.android.build.OutputFile

// For each APK output variant, override versionCode with a combination of
// ext.abiCodes * 1000000 + variant.versionCode. In this example, variant.versionCode
// is equal to defaultConfig.versionCode. If you configure product flavors that
// define their own versionCode, variant.versionCode uses that value instead.
android.applicationVariants.all { variant ->

    // Assigns a different version code for each output APK
    // other than the universal APK.
    variant.outputs.each { output ->

        // Stores the value of ext.abiCodes that is associated with the ABI for this variant.
        def baseAbiVersionCode =
                // Determines the ABI for this variant and returns the mapped value.
                project.ext.abiCodes.get(output.getFilter(OutputFile.ABI))

        // Because abiCodes.get() returns null for ABIs that are not mapped by ext.abiCodes,
        // the following code does not override the version code for universal APKs.
        // However, because we want universal APKs to have the lowest version code,
        // this outcome is desirable.
        if (baseAbiVersionCode != null) {
            // Assigns the new version code to versionCodeOverride, which changes the version code
            // for only the output APK, not for the variant itself. Skipping this step simply
            // causes Gradle to use the value of variant.versionCode for the APK.
            output.versionCodeOverride = baseAbiVersionCode * 1000000 + variant.versionCode
        }
    }
}
```
