import 'package:appkit/ui/base/base.controller.dart';

/// A state that signifies that some operation is in progress.
/// A single instance can be used by multiple operations.
class LoadingState {
  final BaseController? _baseController;

  LoadingState(BaseController? controller) : _baseController = controller;

  int _loadingCount = 0;

  bool get isLoading => _loadingCount > 0;

  void setLoading(bool loading) {
    if (loading) {
      _loadingCount++;
      _baseController?.notifyListeners();
    } else if (_loadingCount > 0) {
      _loadingCount--;
      _baseController?.notifyListeners();
    }
  }
}
