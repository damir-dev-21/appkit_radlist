import 'package:flutter/services.dart';

/// Interacts with the main platform channel.
abstract class AppkitPlatformChannel {
  static const _channel = MethodChannel('kz.appkit');

  static Future<T?> invokeMethod<T>(String method, [dynamic argument]) {
    return _channel.invokeMethod(method, argument);
  }
}
