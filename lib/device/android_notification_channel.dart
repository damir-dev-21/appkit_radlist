import 'dart:io';

import 'package:appkit/common/util/logger.dart';
import 'package:appkit/device/appkit_platform_channel.dart';

const CHANNEL_ID = 'CHANNEL_MAIN';
const CHANNEL_NAME = 'Основной канал';
const CHANNEL_DESCRIPTION = 'Канал для пуш-уведомлений';

abstract class AndroidNotificationChannel {
  static void init() async {
    if (Platform.isAndroid) {
      try {
        final params = <String, String>{
          'id': CHANNEL_ID,
          'name': CHANNEL_NAME,
          'description': CHANNEL_DESCRIPTION,
        };
        await AppkitPlatformChannel.invokeMethod('createMainNotificationChannel', params);
      } catch (error, stacktrace) {
        Log.e('AndroidNotificationChannel.init', error, stacktrace);
      }
    }
  }
}
