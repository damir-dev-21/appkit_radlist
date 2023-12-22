import 'package:connectivity/connectivity.dart';

enum EConnectionState {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none,
}

/// Keeps track of network connection state and provides the current connection state
/// as well as a stream of connection states.
class ConnectionStateProvider {
  late EConnectionState _currentConnectionState;

  EConnectionState get currentConnectionState => _currentConnectionState;

  Stream<EConnectionState> get connectionStateStream => Connectivity()
      .onConnectivityChanged
      .map((connectivityResult) => _mapConnectivityResult(connectivityResult));

  static ConnectionStateProvider? _instance;

  static ConnectionStateProvider? get instance {
    _instance ??= ConnectionStateProvider._();
    return _instance;
  }

  ConnectionStateProvider._() {
    _init();
  }

  ConnectionStateProvider? connectionStateProvider() {
    return instance;
  }

  void _init() async {
    final connectivity = Connectivity();

    connectivity.onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      _currentConnectionState = _mapConnectivityResult(connectivityResult);
    });

    _currentConnectionState = _mapConnectivityResult(await connectivity.checkConnectivity());
  }

  EConnectionState _mapConnectivityResult(ConnectivityResult connectivityResult) {
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return EConnectionState.wifi;
      case ConnectivityResult.mobile:
        return EConnectionState.mobile;
      case ConnectivityResult.none:
        return EConnectionState.none;
      default:
        return EConnectionState.none;
    }
  }
}

extension EConnectionStateExtension on EConnectionState {
  bool get isConnected => this != EConnectionState.none;
}
