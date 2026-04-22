import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({required this.label});

  final String label;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logBlock(
        title: 'REQUEST ${options.method} ${options.baseUrl}${options.path}',
        lines: [
          'query: ${_formatJson(options.queryParameters)}',
          'headers: ${_formatJson(_sanitizeHeaders(options.headers))}',
          'body: ${_formatBody(options.data)}',
        ],
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logBlock(
        title:
            'RESPONSE ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
        lines: [
          'headers: ${_formatJson(_sanitizeHeaders(response.headers.map))}',
          'body: ${_formatBody(response.data)}',
        ],
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final response = err.response;
      _logBlock(
        title:
            'ERROR ${response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}',
        lines: [
          'dioType: ${err.type}',
          'message: ${err.message}',
          'query: ${_formatJson(err.requestOptions.queryParameters)}',
          'headers: ${_formatJson(_sanitizeHeaders(err.requestOptions.headers))}',
          'body: ${_formatBody(err.requestOptions.data)}',
          'response: ${_formatBody(response?.data)}',
        ],
      );
    }

    super.onError(err, handler);
  }

  void _logBlock({required String title, required List<String> lines}) {
    final buffer = StringBuffer()
      ..writeln('')
      ..writeln('[$title]');

    for (final line in lines) {
      buffer.writeln(line);
    }

    log(buffer.toString(), name: 'api:$label');
  }

  String _formatBody(Object? body) {
    if (body == null) {
      return 'null';
    }

    if (body is FormData) {
      final formMap = <String, dynamic>{};
      for (final field in body.fields) {
        formMap[field.key] = _sanitizeValue(field.key, field.value);
      }
      return _formatJson(formMap);
    }

    if (body is Map<String, dynamic>) {
      return _formatJson(_sanitizeMap(body));
    }

    if (body is Map) {
      return _formatJson(
        body.map(
          (key, value) => MapEntry(key.toString(), _sanitizeValue(key, value)),
        ),
      );
    }

    if (body is List) {
      return _formatJson(body.map((item) => _sanitizeDynamic(item)).toList());
    }

    if (body is String) {
      return body;
    }

    return body.toString();
  }

  String _formatJson(Object? value) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map(
      (key, value) => MapEntry(key, _sanitizeValue(key, value)),
    );
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _sanitizeValue(key, value)));
  }

  dynamic _sanitizeDynamic(Object? value) {
    if (value is Map<String, dynamic>) {
      return _sanitizeMap(value);
    }

    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _sanitizeValue(key, nestedValue)),
      );
    }

    if (value is List) {
      return value.map(_sanitizeDynamic).toList();
    }

    return value;
  }

  dynamic _sanitizeValue(Object? key, Object? value) {
    final normalizedKey = key?.toString().toLowerCase() ?? '';

    if (_isSensitiveKey(normalizedKey)) {
      return '***';
    }

    if (value is Map<String, dynamic>) {
      return _sanitizeMap(value);
    }

    if (value is Map) {
      return value.map(
        (nestedKey, nestedValue) => MapEntry(
          nestedKey.toString(),
          _sanitizeValue(nestedKey, nestedValue),
        ),
      );
    }

    if (value is List) {
      return value.map(_sanitizeDynamic).toList();
    }

    return value;
  }

  bool _isSensitiveKey(String key) {
    return key.contains('password') ||
        key.contains('otp') ||
        key.contains('token') ||
        key == 'authorization' ||
        key == 'cookie' ||
        key == 'set-cookie';
  }
}
