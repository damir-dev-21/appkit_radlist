import 'package:appkit/data/network/base_http.dart';

class HttpConfig {
  /// The base URL for all requests (with the exception of [BaseHttp.requestFullUrl]
  String get baseUrl => _baseUrl;
  String _baseUrl;

  /// The header name to be used for sending device info. If null, then device info will not be sent.
  final String? deviceInfoHeader;

  /// The header name to be used for sending a unique request ID. The same request ID
  /// will be used for retries. If null, then no request ID will be sent.
  final String? requestIdHeader;

  /// Whether requests with POST or DELETE HTTP methods will be retried with the same
  /// [requestIdHeader] in the headers.
  final bool retriesEnabledForAllMethods;

  /// Maximum number of times a duplicate request will be attempted in case of
  /// a timeout.
  final int maxRetryCount;

  final int connectTimeout;

  final int receiveTimeout;

  HttpConfig({
    required String baseUrl,
    this.deviceInfoHeader,
    this.requestIdHeader,
    this.retriesEnabledForAllMethods = false,
    this.maxRetryCount = 3,
    this.connectTimeout = 5000,
    this.receiveTimeout = 5000,
  }) : _baseUrl = baseUrl;

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  HttpConfig copyWith({
    String? baseUrl,
    String? deviceInfoHeader,
    String? requestIdHeader,
    bool? retriesEnabledForAllMethods,
    int? maxRetryCount,
    int? connectTimeout,
    int? receiveTimeout,
  }) {
    return HttpConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      deviceInfoHeader: deviceInfoHeader ?? this.deviceInfoHeader,
      requestIdHeader: requestIdHeader ?? this.requestIdHeader,
      retriesEnabledForAllMethods: retriesEnabledForAllMethods ?? this.retriesEnabledForAllMethods,
      maxRetryCount: maxRetryCount ?? this.maxRetryCount,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
    );
  }

}
