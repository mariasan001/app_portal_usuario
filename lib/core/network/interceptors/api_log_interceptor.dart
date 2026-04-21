import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({required this.label});

  final String label;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '[${options.method}] ${options.baseUrl}${options.path}',
        name: 'api:$label',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '[${response.statusCode}] ${response.requestOptions.path}',
        name: 'api:$label',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '[${err.response?.statusCode ?? 'ERR'}] ${err.requestOptions.path} ${err.message}',
        name: 'api:$label',
      );
    }
    super.onError(err, handler);
  }
}
