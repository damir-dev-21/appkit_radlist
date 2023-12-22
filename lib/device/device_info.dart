import 'dart:io';

import 'package:appkit/common/constants/platform.enum.dart';
import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

class DeviceInfo {
  static DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// The multiplier used to differentiate between different builds for different
  /// processor architectures on Android. (Must be used for APK splits in app/build.gradle file).
  static const _buildNumberMultiplier = 1000000;

  /// Return the current build number (the number after '+' in pubspec.yaml's version field).
  static Future<int> getBuildNumber([PackageInfo? packageInfo]) async {
    final info = packageInfo ?? await PackageInfo.fromPlatform();
    final buildNumber = int.parse(info.buildNumber);
    return buildNumber % _buildNumberMultiplier;
  }

  /// Return full device info.
  static Future<DeviceInfo> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = await getBuildNumber(packageInfo);

    if (Platform.isAndroid) {
      final androidInfo = await _plugin.androidInfo;
      return DeviceInfo(
          platform: EPlatform.android,
          model: androidInfo.model,
          osVersion: androidInfo.version.release,
          appBuildNumber: buildNumber,
          appVersion: packageInfo.version,
          sdkInt: androidInfo.version.sdkInt);
    } else {
      final iosInfo = await _plugin.iosInfo;
      return DeviceInfo(
        platform: EPlatform.iOS,
        model: iosInfo.utsname.machine,
        osVersion: iosInfo.systemVersion,
        appBuildNumber: buildNumber,
        appVersion: packageInfo.version,
        systemName: iosInfo.systemName,
      );
    }
  }

  /// Platform: iOS or Android.
  final EPlatform platform;

  /// Device model.
  final String model;

  /// Operating system version.
  final String osVersion;

  /// The build number set in pubspec.yaml after the '+' sign
  final int appBuildNumber;

  /// The version string set in pubspec.yaml before the '+' sign
  final String appVersion;

  final int? sdkInt;

  final String? systemName;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.appBuildNumber,
    required this.appVersion,
    this.sdkInt,
    this.systemName,
  });
}
