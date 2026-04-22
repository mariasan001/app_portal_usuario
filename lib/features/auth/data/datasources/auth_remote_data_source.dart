import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/app_endpoints.dart';
import '../../../../core/device/models/app_device_info.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/auth_user_dto.dart';
import '../dtos/device_check_request_dto.dart';
import '../dtos/device_check_response_dto.dart';
import '../dtos/device_enrollment_confirm_request_dto.dart';
import '../dtos/device_enrollment_confirm_response_dto.dart';
import '../dtos/device_enrollment_request_request_dto.dart';
import '../dtos/device_enrollment_request_response_dto.dart';
import '../dtos/forgot_password_request_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';
import '../dtos/otp_request_request_dto.dart';
import '../dtos/otp_verify_request_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/register_response_dto.dart';
import '../dtos/reset_password_request_dto.dart';
import '../dtos/auth_action_response_dto.dart';

/// DataSource = capa que SI habla HTTP.
///
/// Aqui concentramos las llamadas reales a la API IAM para evitar que la UI
/// o los widgets conozcan URLs, payloads o detalles de Dio.
abstract interface class AuthRemoteDataSource {
  Future<LoginResponseDto> login({
    required String username,
    required String password,
  });

  Future<RegisterResponseDto> register({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  });

  Future<AuthActionResponseDto> forgotPassword({required String email});

  Future<AuthActionResponseDto> requestOtp({
    required String usernameOrEmail,
    required String purpose,
  });

  Future<AuthActionResponseDto> verifyOtp({
    required String usernameOrEmail,
    required String purpose,
    required String otp,
  });

  Future<AuthActionResponseDto> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthUserDto> getCurrentUser();

  Future<DeviceCheckResponseDto> checkDevice({
    required String username,
    required AppDeviceInfo device,
  });

  Future<DeviceEnrollmentRequestResponseDto> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  });

  Future<DeviceEnrollmentConfirmResponseDto> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  });

  Future<String> ping();

  Future<void> clearSession();
}

/// Implementacion concreta del datasource.
///
/// Su trabajo es:
/// 1. armar DTOs de request
/// 2. llamar al ApiClient
/// 3. leer JSON de respuesta
/// 4. convertir ese JSON en DTOs de response
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
  Future<RegisterResponseDto> register({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  }) async {
    final payload = RegisterRequestDto(
      claveSp: claveSp,
      plaza: plaza,
      puesto: puesto,
      email: email,
      password: password,
      phone: phone,
    );
    _debugLogJson('auth.register.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.register,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('auth.register.response', responseJson);
    return RegisterResponseDto.fromJson(responseJson);
  }

  @override
  Future<AuthActionResponseDto> forgotPassword({required String email}) async {
    final payload = ForgotPasswordRequestDto(email: email);
    _debugLogJson('auth.password.forgot.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.passwordForgot,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('auth.password.forgot.response', responseJson);
    return AuthActionResponseDto.fromJson(responseJson);
  }

  @override
  Future<AuthActionResponseDto> requestOtp({
    required String usernameOrEmail,
    required String purpose,
  }) async {
    final payload = OtpRequestRequestDto(
      usernameOrEmail: usernameOrEmail,
      purpose: purpose,
    );
    _debugLogJson('auth.otp.request.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.otpRequest,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('auth.otp.request.response', responseJson);
    return AuthActionResponseDto.fromJson(responseJson);
  }

  @override
  Future<AuthActionResponseDto> verifyOtp({
    required String usernameOrEmail,
    required String purpose,
    required String otp,
  }) async {
    final payload = OtpVerifyRequestDto(
      usernameOrEmail: usernameOrEmail,
      purpose: purpose,
      otp: otp,
    );
    _debugLogJson('auth.otp.verify.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.otpVerify,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('auth.otp.verify.response', responseJson);
    return AuthActionResponseDto.fromJson(responseJson);
  }

  @override
  Future<AuthActionResponseDto> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final payload = ResetPasswordRequestDto(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    _debugLogJson('auth.password.reset.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.passwordReset,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('auth.password.reset.response', responseJson);
    return AuthActionResponseDto.fromJson(responseJson);
  }

  @override
  Future<AuthUserDto> getCurrentUser() async {
    final data = await _apiClient.get<Object?>(IamEndpoints.me);
    return AuthUserDto.fromJson(_readJsonMap(data));
  }

  @override
  Future<DeviceCheckResponseDto> checkDevice({
    required String username,
    required AppDeviceInfo device,
  }) async {
    final payload = DeviceCheckRequestDto.fromDomain(
      username: username,
      device: device,
    );
    _debugLogJson('device.check.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceCheck,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('device.check.response', responseJson);
    return DeviceCheckResponseDto.fromJson(responseJson);
  }

  @override
  Future<DeviceEnrollmentRequestResponseDto> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  }) async {
    final payload = DeviceEnrollmentRequestRequestDto.fromDomain(
      username: username,
      device: device,
    );
    _debugLogJson('device.enroll.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceEnrollRequest,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('device.enroll.request.response', responseJson);
    return DeviceEnrollmentRequestResponseDto.fromJson(responseJson);
  }

  @override
  Future<DeviceEnrollmentConfirmResponseDto> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  }) async {
    final payload = DeviceEnrollmentConfirmRequestDto.fromDomain(
      enrollmentId: enrollmentId,
      otp: otp,
      username: username,
    );
    _debugLogJson('device.enroll.confirm.request', payload.toJson());

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceEnrollConfirm,
      data: payload.toJson(),
    );

    final responseJson = _readJsonMap(data);
    _debugLogJson('device.enroll.confirm.response', responseJson);
    return DeviceEnrollmentConfirmResponseDto.fromJson(responseJson);
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

  void _debugLogJson(String label, Map<String, dynamic> json) {
    if (!kDebugMode) {
      return;
    }

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('[$label]');
    debugPrint(encoder.convert(json));
  }
}
