import 'package:appkit/common/util/logger.dart';
import 'package:appkit/framework/event_bus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_storage.dart';

const _LS_KEY_DID_INITIALIZE_SECURE_STORAGE = 'kz.didInitializeSecureStorage';

class SecureStorage {
  late final LocalStorage _localStorage;

  bool _isInitialized = false;
  Future<void>? _initFuture;

  SecureStorage({required LocalStorage localStorage}) : _localStorage = localStorage {
    _init();
  }

  Future<void>? _init() {
    if (_initFuture != null) {
      return _initFuture;
    }

    if (!_isInitialized) {
      _initFuture = _doInit().then((_) {
        _isInitialized = true;
      }).whenComplete(() {
        _initFuture = null;
      });
    }
    return _initFuture;
  }

  Future<void> _doInit() async {
    final didInitialize = _localStorage.getBool(_LS_KEY_DID_INITIALIZE_SECURE_STORAGE);
    if (!didInitialize) {
      await _storage.deleteAll();
      await _localStorage.putBool(_LS_KEY_DID_INITIALIZE_SECURE_STORAGE, true);
      EventBus.instance.send(CleanupEvent());
    }
  }

  final _storage = FlutterSecureStorage();

  Future<String?> read(String key) async {
    await _init();
    try {
      return _storage.read(key: key);
    } catch (error, stacktrace) {
      Log.e('SecureStorage.read', error, stacktrace);

      return throw error.toString();
    }
  }

  Future<void> write(String key, dynamic value) async {
    await _init();
    try {
      _storage.write(key: key, value: value.toString());
    } catch (error, stacktrace) {
      Log.e('SecureStorage.write', error, stacktrace);
    }

    return;
  }

  Future<void> remove(String key) async {
    try {
      _storage.delete(key: key);
    } catch (error, stacktrace) {
      Log.e('SecureStorage.remove', error, stacktrace);
    }

    return;
  }
}
