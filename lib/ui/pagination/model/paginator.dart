import 'package:loading_more_list/loading_more_list.dart';

abstract class Paginator<T> extends LoadingMoreBase<T> {
  void onRefresh();

  void Function(bool notifyStateChanged)? refreshListener;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    final refreshListener = this.refreshListener;
    if (refreshListener != null) {
      refreshListener(notifyStateChanged);
    } else {
      onRefresh();
      if (notifyStateChanged) {
        isLoading = false;
      }
    }
    return super.refresh(notifyStateChanged);
  }

  int get elementCount => length;
}
