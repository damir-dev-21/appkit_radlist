import 'package:appkit/common/util/app_error.dart';

enum EPlatform {
  iOS,
  android,
}

extension EPlatformExtension on EPlatform {
  int get value {
    switch (this) {
      case EPlatform.iOS:
        return 1;
      case EPlatform.android:
        return 2;
      default:
        throw AppError('Invalid Platform: $this');
    }
  }
}
