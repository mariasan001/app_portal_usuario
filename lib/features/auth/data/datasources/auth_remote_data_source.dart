import '../../../../core/config/app_endpoints.dart';
import '../../../../core/device/models/app_device_info.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/auth_action_response_dto.dart';
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
import '../dtos/register_request_dto.dart';
import '../dtos/register_response_dto.dart';
import '../dtos/reset_password_request_dto.dart';

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

    final data = await _apiClient.post<Object?>(
      IamEndpoints.register,
      data: payload.toJson(),
    );

    return RegisterResponseDto.fromJson(_readJsonMap(data));
  }

  @override
  Future<AuthActionResponseDto> forgotPassword({required String email}) async {
    final payload = ForgotPasswordRequestDto(email: email);

    final data = await _apiClient.post<Object?>(
      IamEndpoints.passwordForgot,
      data: payload.toJson(),
    );

    return AuthActionResponseDto.fromJson(_readJsonMap(data));
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

    final data = await _apiClient.post<Object?>(
      IamEndpoints.passwordReset,
      data: payload.toJson(),
    );

    return AuthActionResponseDto.fromJson(_readJsonMap(data));
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

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceCheck,
      data: payload.toJson(),
    );

    return DeviceCheckResponseDto.fromJson(_readJsonMap(data));
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

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceEnrollRequest,
      data: payload.toJson(),
    );

    return DeviceEnrollmentRequestResponseDto.fromJson(_readJsonMap(data));
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

    final data = await _apiClient.post<Object?>(
      IamEndpoints.deviceEnrollConfirm,
      data: payload.toJson(),
    );

    return DeviceEnrollmentConfirmResponseDto.fromJson(_readJsonMap(data));
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
