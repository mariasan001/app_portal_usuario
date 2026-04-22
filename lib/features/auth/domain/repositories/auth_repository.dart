import '../../../../core/device/models/app_device_info.dart';
import '../entities/device/device_check_result.dart';
import '../entities/device/device_enrollment_confirm_result.dart';
import '../entities/device/device_enrollment_request_result.dart';
import '../entities/recovery/auth_action_result.dart';
import '../entities/session/auth_user.dart';
import '../entities/session/login_result.dart';
import '../entities/session/register_result.dart';

/// Repository = frontera entre la capa de negocio y la capa de datos.
///
/// El resto de la app depende de esta interfaz y no de Dio ni del backend.
/// Asi podemos cambiar la fuente de datos sin romper controller, use cases o UI.
abstract interface class AuthRepository {
  Future<LoginResult> login({
    required String username,
    required String password,
  });

  Future<RegisterResult> register({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  });

  Future<AuthActionResult> forgotPassword({required String email});

  Future<AuthActionResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthUser> getCurrentUser();

  Future<DeviceCheckResult> checkDevice({
    required String username,
    required AppDeviceInfo device,
  });

  Future<DeviceEnrollmentRequestResult> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  });

  Future<DeviceEnrollmentConfirmResult> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  });

  Future<void> clearSession();
}
