import '../../../../core/device/models/app_device_info.dart';
import '../../domain/entities/auth_action_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/device_check_result.dart';
import '../../domain/entities/device_enrollment_confirm_result.dart';
import '../../domain/entities/device_enrollment_request_result.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementacion del repository de auth.
///
/// Aqui aterrizamos la interfaz del dominio usando el datasource remoto.
/// Su responsabilidad principal es convertir DTOs a entidades de dominio.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    return response.toDomain();
  }

  @override
  Future<RegisterResult> register({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _remoteDataSource.register(
      claveSp: claveSp,
      plaza: plaza,
      puesto: puesto,
      email: email,
      password: password,
      phone: phone,
    );

    return response.toDomain();
  }

  @override
  Future<AuthActionResult> forgotPassword({required String email}) async {
    final response = await _remoteDataSource.forgotPassword(email: email);
    return response.toDomain();
  }

  @override
  Future<AuthActionResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    return response.toDomain();
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    final response = await _remoteDataSource.getCurrentUser();
    return response.toDomain();
  }

  @override
  Future<DeviceCheckResult> checkDevice({
    required String username,
    required AppDeviceInfo device,
  }) async {
    final response = await _remoteDataSource.checkDevice(
      username: username,
      device: device,
    );
    return response.toDomain();
  }

  @override
  Future<DeviceEnrollmentRequestResult> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  }) async {
    final response = await _remoteDataSource.requestDeviceEnrollment(
      username: username,
      device: device,
    );
    return response.toDomain();
  }

  @override
  Future<DeviceEnrollmentConfirmResult> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  }) async {
    final response = await _remoteDataSource.confirmDeviceEnrollment(
      enrollmentId: enrollmentId,
      otp: otp,
      username: username,
    );
    return response.toDomain();
  }

  @override
  Future<void> clearSession() => _remoteDataSource.clearSession();
}
