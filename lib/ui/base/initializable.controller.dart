import 'package:appkit/common/observable_model/value_model.dart';
import 'package:appkit/ui/model/loading_state.dart';
import 'package:flutter/foundation.dart';

import 'base.controller.dart';

/// Controller class that defines common logic for root screens, which
/// usually need some asynchronous initialization logic to be executed before
/// letting the user interact with them.
abstract class InitializableController extends BaseController {
  /// Run the initialization logic and return the Future, which is resolved
  /// when the controller should be marked as initialized.
  @protected
  Future<void> init();

  late LoadingState _loadingState;
  late ValueModel<bool> _hasError;
  late ValueModel<bool> _isInitialized;

  InitializableController() {
    _loadingState = LoadingState(this);
    _hasError = ValueModel(initialVal: false, controller: this);
    _isInitialized = ValueModel(initialVal: false, controller: this);
  }

  @protected
  LoadingState get loadingState => _loadingState;

  bool get isLoading => _loadingState.isLoading;

  bool get hasError => _hasError.val == true;

  bool get isInitialized => _isInitialized.val == true;

  final _initializationListeners = <VoidCallback>[];

  void setHasError(bool value) {
    _hasError.val = value;
  }

  Future<void> reload() {
    return initialize(reload: true);
  }

  Future<void> initialize({bool reload = false}) async {
    if (isLoading) {
      return;
    }

    if (!reload && isInitialized == true && hasError == false) {
      return;
    }

    _hasError.val = false;
    await init();
    _isInitialized.val = true;
    _initializationListeners.forEach((it) => it());
  }

  /// Add a listener function that will be invoked after the controller is initialized.
  /// Note that the listener can be invoked multiple times if [reload] is called.
  void addInitializationListener(VoidCallback listener) {
    _initializationListeners.add(listener);
  }

  void removeInitializationListener(VoidCallback listener) {
    _initializationListeners.remove(listener);
  }
}
