import 'package:dio/dio.dart';

import '../../../../core/config/app_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/auth_user_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseDto> login({
    required String username,
    required String password,
  });

  Future<AuthUserDto> getCurrentUser();

  Future<String> ping();

  Future<void> clearSession();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LoginResponseDto> login({
    required String username,
    required String password,
  }) async {
    final data = await _apiClient.post<Object?>(
      IamEndpoints.login,
      data: LoginRequestDto.fromCredentials(
        username: username,
        password: password,
      ).toJson(),
    );

    return LoginResponseDto.fromJson(_readJsonMap(data));
  }

  @override
  Future<AuthUserDto> getCurrentUser() async {
    final data = await _apiClient.get<Object?>(IamEndpoints.me);
    return AuthUserDto.fromJson(_readJsonMap(data));
  }

  @override
  Future<String> ping() async {
    final data = await _apiClient.get<Object?>(
      IamEndpoints.ping,
      options: Options(responseType: ResponseType.plain),
    );

    if (data is String) {
      return data;
    }

    return data?.toString() ?? '';
  }

  @override
  Future<void> clearSession() => _apiClient.clearSession();

  Map<String, dynamic> _readJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    throw StateError('La respuesta no tiene el formato JSON esperado.');
  }
}
