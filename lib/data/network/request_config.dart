import 'package:dio/dio.dart';

import 'http_method.dart';
import 'utils/multipart_file_wrapper.dart';

class RequestConfig {
  HttpMethod method;
  String url;
  Map<String, String>? headers;
  String? body;
  FormData? formData;
  Map<String, dynamic>? query;
  CancelToken? cancelToken;

  /// List of non-file fields for a multipart/form-data request.
  List<MapEntry<String, String>>? multipartFields;

  /// List of files to be sent with a multipart/form-data request.
  List<MapEntry<String, MultipartFileWrapper>>? multipartFiles;

  int? timeoutMs;
  int retryCount;

  ResponseType? responseType;

  RequestConfig({
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.formData,
    this.query,
    this.multipartFields,
    this.multipartFiles,
    this.timeoutMs,
    this.retryCount = 0,
    this.responseType,
    this.cancelToken,
  });

  RequestConfig copyWith({
    HttpMethod? method,
    String? url,
    Map<String, String>? headers,
    String? body,
    FormData? formData,
    Map<String, dynamic>? query,
    int? timeoutMs,
    int? retryCount,
    CancelToken? cancelToken,
  }) {
    return RequestConfig(
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      formData: formData ?? this.formData,
      query: query ?? this.query,
      multipartFields: this.multipartFields,
      multipartFiles: this
          .multipartFiles
          ?.where((element) => element.value.clone() != null)
          .map((entry) => MapEntry(entry.key, entry.value.clone()!))
          .toList(),
      timeoutMs: timeoutMs ?? this.timeoutMs,
      retryCount: retryCount ?? this.retryCount,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  /// Create a FormData object to be sent with a multipart/form-data request.
  FormData? createMultipartFormData() {
    if (multipartFields?.isNotEmpty == true && multipartFiles?.isNotEmpty == true) {
      final formData = FormData();
      final multipartFields = this.multipartFields;
      if (multipartFields != null && multipartFields.isNotEmpty) {
        formData.fields.addAll(multipartFields);
      }
      final multipartFiles = this.multipartFiles;
      if (multipartFiles != null && multipartFiles.isNotEmpty) {
        formData.files.addAll(
          multipartFiles.map((entry) => MapEntry(entry.key, entry.value.multipartFile)).toList(),
        );
      }
      return formData;
    }
    return null;
  }
}
