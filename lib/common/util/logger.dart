import 'dart:developer' as developer;

import 'package:logger/logger.dart' as FancyLogger;

final Log = FancyLogger.Logger(printer: FancyLogger.PrettyPrinter(colors: false));

final _simpleLog = FancyLogger.Logger(printer: FancyLogger.SimplePrinter(colors: false));

class Logger {
  String _tag;

  Logger(this._tag);

  void log(dynamic message) {
    _simpleLog.d('[$_tag] ($_formattedTime): $message');
  }

  /// Log the message. This method differs from [log] in that long lines do not
  /// get clipped when using [devLog].
  void devLog(dynamic message) {
    developer.log('[$_tag] ($_formattedTime): $message');
  }

  String get _formattedTime {
    final now = DateTime.now();
    return '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }
}
