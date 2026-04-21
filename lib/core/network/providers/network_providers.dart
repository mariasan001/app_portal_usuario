import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_environment.dart';
import '../api_client.dart';
import '../interceptors/api_log_interceptor.dart';

final iamCookieJarProvider = Provider<CookieJar>((ref) {
  return CookieJar();
});

final iamDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.baseUrlFor(ApiModule.iam),
      headers: const {'Accept': 'application/json, text/plain, */*'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(CookieManager(ref.watch(iamCookieJarProvider)));
  dio.interceptors.add(ApiLogInterceptor(label: 'iam'));

  return dio;
});

final iamApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(iamDioProvider),
    cookieJar: ref.watch(iamCookieJarProvider),
  );
});
