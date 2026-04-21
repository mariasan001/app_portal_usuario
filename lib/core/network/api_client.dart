import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiClient {
  ApiClient({required Dio dio, required CookieJar cookieJar})
    : _dio = dio,
      _cookieJar = cookieJar;

  final Dio _dio;
  final CookieJar _cookieJar;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> clearSession() => _cookieJar.deleteAll();
}
