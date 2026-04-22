import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/core/device/device_metadata_collector.dart';
import 'package:portal_servicios_usuario/core/device/models/app_device_info.dart';
import 'package:portal_servicios_usuario/core/network/api_exception.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/auth_action_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/auth_user.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_check_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_enrollment_confirm_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_enrollment_request_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/login_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/register_result.dart';
import 'package:portal_servicios_usuario/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('AuthController', () {
    late FakeAuthRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          deviceMetadataCollectorServiceProvider.overrideWithValue(
            FakeDeviceMetadataCollector(),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test(
      'login autentica cuando credenciales y dispositivo son validos',
      () async {
        final controller = container.read(authControllerProvider.notifier);
        await Future<void>.delayed(Duration.zero);

        final success = await controller.login(
          username: '210049376',
          password: 'Secreto123',
        );

        final state = container.read(authControllerProvider);
        expect(success, isTrue);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.username, '210049376');
      },
    );

    test(
      'login bloquea acceso y deja pendiente el usuario si el dispositivo no coincide',
      () async {
        repository.deviceCheckResult = const DeviceCheckResult(
          code: DeviceCheckCode.deviceNotEnrolled,
          rawCode: 'DEVICE_NOT_ENROLLED',
          message: 'Dispositivo no enrolado',
        );

        final controller = container.read(authControllerProvider.notifier);
        await Future<void>.delayed(Duration.zero);

        final success = await controller.login(
          username: '210049376',
          password: 'Secreto123',
        );

        final state = container.read(authControllerProvider);
        expect(success, isFalse);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.pendingUsername, '210049376');
        expect(state.deviceCheckResult?.requiresEnrollment, isTrue);
        expect(repository.clearSessionCalled, isTrue);
      },
    );

    test(
      'forgotPassword guarda mensaje informativo cuando la API responde OK',
      () async {
        final controller = container.read(authControllerProvider.notifier);
        await Future<void>.delayed(Duration.zero);

        final result = await controller.forgotPassword(
          email: 'persona@edomex.gob.mx',
        );

        final state = container.read(authControllerProvider);
        expect(result?.ok, isTrue);
        expect(
          state.infoMessage,
          'Te enviamos un codigo de verificacion a tu correo.',
        );
      },
    );

    test('resetPassword guarda error cuando la API falla', () async {
      repository.failResetPassword = true;
      final controller = container.read(authControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await controller.resetPassword(
        email: 'persona@edomex.gob.mx',
        otp: '483921',
        newPassword: 'NuevaPassword#2026',
      );

      final state = container.read(authControllerProvider);
      expect(result, isNull);
      expect(state.errorMessage, 'OTP invalido');
    });

    test(
      'signOutLocally limpia sesion y deja el estado sin autenticar',
      () async {
        final controller = container.read(authControllerProvider.notifier);
        await Future<void>.delayed(Duration.zero);

        await controller.login(username: '210049376', password: 'Secreto123');
        expect(container.read(authControllerProvider).isAuthenticated, isTrue);

        await controller.signOutLocally();

        final state = container.read(authControllerProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(repository.clearSessionCalled, isTrue);
      },
    );
  });
}

class FakeDeviceMetadataCollector implements DeviceMetadataCollector {
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

class FakeAuthRepository implements AuthRepository {
  int _getCurrentUserCalls = 0;

  bool clearSessionCalled = false;
  bool failResetPassword = false;

  DeviceCheckResult deviceCheckResult = const DeviceCheckResult(
    code: DeviceCheckCode.ok,
    rawCode: 'OK',
    message: 'Dispositivo reconocido',
  );

  final AuthUser authUser = const AuthUser(
    userId: 25,
    username: '210049376',
    email: 'persona@edomex.gob.mx',
    spId: 'SP001',
    status: 'ACTIVE',
    roles: ['ROLE_USER'],
  );

  @override
  Future<void> clearSession() async {
    clearSessionCalled = true;
  }

  @override
  Future<DeviceCheckResult> checkDevice({
    required String username,
    required AppDeviceInfo device,
  }) async {
    return deviceCheckResult;
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
    return const AuthActionResult(ok: true, message: 'OTP enviado al correo');
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    _getCurrentUserCalls++;
    if (_getCurrentUserCalls == 1) {
      throw ApiException(message: 'Sin sesion');
    }
    return authUser;
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
    if (failResetPassword) {
      throw ApiException(message: 'OTP invalido', statusCode: 400);
    }

    return const AuthActionResult(ok: true, message: 'Password actualizado');
  }
}
