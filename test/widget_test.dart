import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/app/app.dart';
import 'package:portal_servicios_usuario/core/device/device_metadata_collector.dart';
import 'package:portal_servicios_usuario/core/device/models/app_device_info.dart';
import 'package:portal_servicios_usuario/core/network/api_exception.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/auth_action_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/auth_user.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_check_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_enrollment_confirm_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_enrollment_request_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/login_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/register_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/repositories/auth_repository.dart';

void main() {
  testWidgets('Arranca la app', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_BootstrapAuthRepository()),
          deviceMetadataCollectorServiceProvider.overrideWithValue(
            _BootstrapDeviceMetadataCollector(),
          ),
        ],
        child: const App(),
      ),
    );

    await tester.pump();

    expect(find.byType(App), findsOneWidget);
  });
}

class _BootstrapDeviceMetadataCollector implements DeviceMetadataCollector {
  @override
  Future<AppDeviceInfo> collect() async {
    return const AppDeviceInfo(
      deviceIdFinal: 'device-final',
      fingerprintId: 'fingerprint',
      brand: 'ZTE',
      model: 'Z2450',
      platform: 'ANDROID',
      osVersion: '14',
      arch: 'arm64-v8a',
      appVersion: '1.0.0+1',
    );
  }
}

class _BootstrapAuthRepository implements AuthRepository {
  @override
  Future<void> clearSession() async {}

  @override
  Future<DeviceCheckResult> checkDevice({
    required String username,
    required AppDeviceInfo device,
  }) async {
    return const DeviceCheckResult(
      code: DeviceCheckCode.ok,
      rawCode: 'OK',
      message: 'Dispositivo reconocido',
    );
  }

  @override
  Future<DeviceEnrollmentConfirmResult> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  }) async {
    return const DeviceEnrollmentConfirmResult(
      code: 'OK',
      message: 'Dispositivo enrolado',
      deviceIdHash: 'hash-final',
    );
  }

  @override
  Future<AuthActionResult> forgotPassword({required String email}) async {
    return const AuthActionResult(ok: true, message: 'OTP enviado');
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    throw ApiException(message: 'Sin sesion');
  }

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    return const LoginResult(
      username: '210049376',
      userId: 25,
      message: 'Login correcto',
    );
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
    return const RegisterResult(
      userId: 10,
      username: '210048332',
      status: 'ACTIVE',
      message: 'Registro exitoso',
    );
  }

  @override
  Future<DeviceEnrollmentRequestResult> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  }) async {
    return const DeviceEnrollmentRequestResult(
      code: 'OTP_SENT',
      message: 'Codigo enviado',
      enrollmentId: 'enroll-001',
    );
  }

  @override
  Future<AuthActionResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return const AuthActionResult(ok: true, message: 'Password actualizado');
  }
}
