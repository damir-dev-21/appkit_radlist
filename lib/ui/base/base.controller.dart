import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class BaseController with ChangeNotifier {
  bool _isDisposed = false;

  bool _didScheduleNotifyListeners = false;

  void notifyListeners() {
    if (!_isDisposed) {
      // In order to avoid calling super.notifyListeners() multiple times in a row,
      // we schedule it to be called at the end of the frame, once for a batch of calls
      // to this.notifyListeners().
      if (!_didScheduleNotifyListeners) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            super.notifyListeners();
          }
          // Release the guard after notification occurred
          // (notice that this line is inside PostFrameCallback)
          _didScheduleNotifyListeners = false;
        });
        // Just in case a frame is not scheduled yet, we schedule it manually.
        SchedulerBinding.instance.scheduleFrame();
      }
      _didScheduleNotifyListeners = true;
    }
  }

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      super.dispose();
    }
  }
}
