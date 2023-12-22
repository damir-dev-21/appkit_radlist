import 'package:dio/dio.dart';

class ResponseWrapper {
  final Response? response;
  final DioError? error;

  ResponseWrapper({
    this.response,
    this.error,
  });
}
