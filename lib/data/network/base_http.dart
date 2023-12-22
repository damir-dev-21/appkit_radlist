import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appkit/common/constants/platform.enum.dart';
import 'package:appkit/common/util/logger.dart';
import 'package:appkit/data/network/http_config.dart';
import 'package:appkit/data/network/utils/http_utils.dart';
import 'package:appkit/data/network/utils/response_wrapper.dart';
import 'package:appkit/data/operation_result.dart';
import 'package:appkit/device/device_info.dart';
import 'package:appkit/framework/event_bus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

import 'http_method.dart';
import 'request_config.dart';

/// Handles HTTP requests. Applications should create their own Http class that extends this one,
/// and add extra functionality if needed.
abstract class BaseHttp {
  final HttpConfig _config;

  late Dio _dio;

  /// In order to avoid duplicate requests, their Future<Response>'s are
  /// cached by URL + _cleanupTimestamp combination.
  final Map<String, Future<ResponseWrapper>> _getRequestCache = {};

  /// Timestamp set when a [CleanupEvent] is received. Used to determine
  /// if an in-progress request is still valid when the response is received.
  /// For example, a request may be initiated before the CleanupEvent,,
  /// and the response is received after the CleanupEvent, so it may no longer
  /// be valid. We check that this timestamp is changed after getting a response,
  /// and if so, return an error.
  int _cleanupTimestamp = 0;

  /// Used to generate UUIDs to put into request headers which will identify
  /// duplicate requests (important in case of POST/PUT/PATCH/DELETE requests).
  final _uuid = Uuid();

  final _logger = Logger('Http');

  BaseHttp(HttpConfig config) : _config = config {
    initialize();

    EventBus.instance.onEvent<CleanupEvent>(() {
      _cleanupTimestamp = DateTime.now().millisecondsSinceEpoch;
    });

    _dio = _createHttpClient(_config);

    if (_config.deviceInfoHeader != null) {
      _initDeviceInfoHeader();
    }
  }

  /// Run initialization logic if needed.
  @protected
  void initialize() {}

  /// Return a list of custom interceptors that should be added to the Dio instance.
  @protected
  Iterable<Interceptor>? configureInterceptors() {
    return null;
  }

  Dio _createHttpClient(HttpConfig config) {
    final dio = Dio(BaseOptions(
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    final interceptors = configureInterceptors();
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }

    return dio;
  }

  String get baseUrl => _config.baseUrl;

  void setBaseUrl(String baseUrl) {
    _logger.log('Setting baseUrl to $baseUrl');
    _config.setBaseUrl(baseUrl);
  }

  /// The header value that is sent with every request containing device info.
  String get deviceInfoHeader => _dio.options.headers[_config.deviceInfoHeader];

  void _initDeviceInfoHeader() async {
    final deviceInfo = await DeviceInfo.getDeviceInfo();
    final deviceInfoHeader = _config.deviceInfoHeader;
    if (deviceInfoHeader != null)
      _dio.options.headers[deviceInfoHeader] = jsonEncode({
        'platform': deviceInfo.platform.value,
        'device_model': deviceInfo.model,
        'os_version': deviceInfo.osVersion,
        'app_version': deviceInfo.appBuildNumber,
      });
  }

  Map<String, dynamic> getDefaultHeaders() {
    return _dio.options.headers;
  }

  void setDefaultHeaders(Map<String, dynamic> headers) {
    headers.forEach((key, value) {
      _dio.options.headers[key] = value;
    });
  }

  void removeDefaultHeaders(List<String> headers) {
    headers.forEach((header) {
      _dio.options.headers.remove(header);
    });
  }

  Future<ResponseWrapper> request({
    required HttpMethod method,
    required String path,
    Map<String, String>? headers,
    String? body,
    FormData? formData,
    Map<String, dynamic>? query,
    ResponseType? responseType,
    int timeoutMs = 0,
    CancelToken? cancelToken,
  }) async {
    return requestUsingConfig(
      RequestConfig(
        method: method,
        url: makeFullUrl(path),
        headers: headers,
        body: body,
        formData: formData,
        query: query,
        timeoutMs: timeoutMs,
        responseType: responseType,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<ResponseWrapper> requestFullUrl({
    required HttpMethod method,
    required String url,
    Map<String, String>? headers,
    String? body,
    FormData? formData,
    Map<String, dynamic>? query,
    ResponseType? responseType,
    int timeoutMs = 0,
  }) async {
    return requestUsingConfig(RequestConfig(
      method: method,
      url: url,
      headers: headers,
      body: body,
      formData: formData,
      query: query,
      timeoutMs: timeoutMs,
      responseType: responseType,
    ));
  }

  String _makeGetRequestCacheKey(String url) {
    return '$url-$_cleanupTimestamp';
  }

  @protected
  String makeFullUrl(String path) {
    return '${_config.baseUrl}$path';
  }

  /// Send a multipart/form-data request using the given [method] to an endpoint
  /// located at [path] with the request body containing the [fields], [files] and [filesAsBytes].
  /// [files] is a list of files to be attached.
  /// [filesAsBytes] is a map where each key is a file name and the values are the contents
  /// of files to be attached as lists of bytes.
  /// If [serializeNulls] is set to true, then [fields] with null values are included in
  /// the request.
  Future<ResponseWrapper> sendMultipartRequest({
    required HttpMethod method,
    required String path,
    required File file,
    String? fileName,
  }) async {
    String name = fileName ?? file.path.split('/').last;
    if (name.length > 100) {
      name = name.substring(0, 100);
    }
    FormData formData = FormData.fromMap({
      'path': await MultipartFile.fromFile(
        file.path,
        filename: name,
        contentType: MediaType.parse('multipart/form-data'),
      ),
    });

    return requestUsingConfig(RequestConfig(
      method: method,
      url: makeFullUrl(path),
      formData: formData,
    ));
  }

  @protected
  Future<ResponseWrapper> requestUsingConfig(
    RequestConfig config, {
    String? requestId,
  }) async {
    String url = config.url;
    final query = config.query;
    if (query != null) {
      url += HttpUtils.formatQueryString(query);
    }
    final cacheKey = _makeGetRequestCacheKey(url);
    if (config.method == HttpMethod.GET &&
        _getRequestCache.containsKey(cacheKey) &&
        config.retryCount == 0) {
      return _getRequestCache[cacheKey]!;
    }

    _logger.log('${config.method.name} $url');

    final data = config.formData ?? config.body ?? config.createMultipartFormData();
    _logRequestBody(data);

    String requestIdHeader = requestId ?? _uuid.v4();
    final headers = <String, dynamic>{};
    final configRequestIdHeader = _config.requestIdHeader;
    if (configRequestIdHeader != null) {
      headers[configRequestIdHeader] = requestIdHeader;
      final configHeaders = config.headers;
      if (configHeaders != null) {
        headers.addAll(configHeaders);
      }
    }

    final options = Options(
      method: config.method.name,
      headers: headers,
    );

    if (config.responseType != null) {
      options.responseType = config.responseType;
    }

    Future<Response> responseFuture = _dio.request(
      url,
      data: data,
      options: options,
      cancelToken: config.cancelToken,
    );

    // We declare the timeout via connectTimeout here, because receiveTimeout and sendTimeout
    // of Dio.Options are not working for some reason.
    final timeoutMs = config.timeoutMs;
    if (timeoutMs != null) {
      _dio.options.connectTimeout = timeoutMs;
    }

    Future<ResponseWrapper> responseWrapperFuture = _applyRetries(
      responseFuture: responseFuture,
      config: config,
      requestId: requestIdHeader,
    );

    if (config.method == HttpMethod.GET) {
      _getRequestCache[cacheKey] = responseWrapperFuture;
      responseFuture.whenComplete(() {
        _getRequestCache.remove(cacheKey);
      });
    }

    final responseWrapper = await _cancelOnCleanup(responseWrapperFuture);

    _logger.log('Response (${responseWrapper.response?.statusCode}): ${responseWrapper.response}');

    return responseWrapper;
  }

  void _logRequestBody(dynamic data) {
    if (data != null) {
      if (data is FormData) {
        _logger.devLog('FormData {'
            '  fields: ${Map.fromEntries(data.fields)},'
            '  files: ${data.files.map((entry) => entry.value.length)}'
            '}');
      } else {
        _logger.devLog(data);
      }
    }
  }

  Future<T> _cancelOnCleanup<T>(Future<T> responseFuture) async {
    final initialCleanupTimestamp = _cleanupTimestamp;
    final response = await responseFuture;
    if (_cleanupTimestamp != initialCleanupTimestamp) {
      _logger.log('Cancelled');
      return Future.error(OperationCancelled());
    }
    return response;
  }

  Future<ResponseWrapper> _applyRetries({
    required Future<Response> responseFuture,
    required RequestConfig config,
    required String requestId,
  }) async {
    final DateTime requestStartTime = DateTime.now();
    ResponseWrapper? wrapper;
    Response? response;
    DioError? error;

    try {
      response = await responseFuture;

      final requestEndTime = DateTime.now();
      _logger.log('${config.method.name} ${config.url} took ' +
          '${requestEndTime.difference(requestStartTime).inMilliseconds}ms');
    } catch (e, stacktrace) {
      if (e is DioError) {
        final isTimeout = e.type == DioErrorType.connectTimeout ||
            e.type == DioErrorType.receiveTimeout ||
            e.type == DioErrorType.sendTimeout;

        if (isTimeout && (config.method.isRepeatable || _config.retriesEnabledForAllMethods)) {
          wrapper = await _retryRequest(config, requestId);
        } else {
          error = e;
          response = e.response;
        }
      } else {
        Log.e('_applyRetries', e, stacktrace);
        throw e;
      }
    }

    return ResponseWrapper(
      response: response ?? wrapper?.response,
      error: error ?? wrapper?.error,
    );
  }

  Future<ResponseWrapper> _retryRequest(RequestConfig config, String requestId) async {
    if (config.retryCount >= _config.maxRetryCount) {
      return ResponseWrapper(
        error: DioError(
          type: DioErrorType.other,
          error: HttpException('Сервер не отвечает. Проверьте свое подключение к интернету.'),
          requestOptions: RequestOptions(path: config.url),
        ),
      );
    } else {
      _logger.log('Retrying request for ${config.retryCount + 1} time');
      return requestUsingConfig(
        config.copyWith(retryCount: config.retryCount + 1),
        requestId: requestId,
      );
    }
  }
}
