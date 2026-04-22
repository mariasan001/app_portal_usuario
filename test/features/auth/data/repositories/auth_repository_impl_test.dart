import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/core/device/models/app_device_info.dart';
import 'package:portal_servicios_usuario/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/auth_action_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/auth_user_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/device_check_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/device_enrollment_confirm_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/device_enrollment_request_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/login_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/register_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device_check_result.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late FakeAuthRemoteDataSource remoteDataSource;
    late AuthRepositoryImpl repository;

    const device = AppDeviceInfo(
      deviceIdFinal: 'device-final',
      fingerprintId: 'fingerprint',
      brand: 'ZTE',
      model: 'Z2450',
      platform: 'ANDROID',
      osVersion: '14',
      arch: 'arm64-v8a',
      appVersion: '1.0.0+1',
    );

    setUp(() {
      remoteDataSource = FakeAuthRemoteDataSource();
      repository = AuthRepositoryImpl(remoteDataSource);
    });

    test('login convierte LoginResponseDto a LoginResult', () async {
      final result = await repository.login(
        username: '210049376',
        password: 'Secreto123',
      );

      expect(result.username, '210049376');
      expect(result.userId, 25);
      expect(result.message, 'Login correcto');
      expect(remoteDataSource.lastLoginUsername, '210049376');
    });

    test('register convierte RegisterResponseDto a RegisterResult', () async {
      final result = await repository.register(
        claveSp: '210048332',
        plaza: '234000000002125',
        puesto: 'ANALISTA',
        email: 'persona@edomex.gob.mx',
        password: 'MiPassword#2026',
        phone: '7221234567',
      );

      expect(result.userId, 10);
      expect(result.username, '210048332');
      expect(result.status, 'ACTIVE');
    });

    test(
      'forgotPassword convierte AuthActionResponseDto a AuthActionResult',
      () async {
        final result = await repository.forgotPassword(
          email: 'persona@edomex.gob.mx',
        );

        expect(result.ok, isTrue);
        expect(result.message, 'OTP enviado');
        expect(
          remoteDataSource.lastForgotPasswordEmail,
          'persona@edomex.gob.mx',
        );
      },
    );

    test(
      'resetPassword convierte AuthActionResponseDto a AuthActionResult',
      () async {
        final result = await repository.resetPassword(
          email: 'persona@edomex.gob.mx',
          otp: '483921',
          newPassword: 'NuevaPassword#2026',
        );

        expect(result.ok, isTrue);
        expect(result.message, 'Password actualizado');
        expect(remoteDataSource.lastResetPasswordOtp, '483921');
      },
    );

    test('getCurrentUser convierte AuthUserDto a AuthUser', () async {
      final result = await repository.getCurrentUser();

      expect(result.userId, 25);
      expect(result.username, '210049376');
      expect(result.roles, ['ROLE_USER']);
    });

    test('checkDevice convierte respuesta a DeviceCheckResult', () async {
      final result = await repository.checkDevice(
        username: '210049376',
        device: device,
      );

      expect(result.code, DeviceCheckCode.deviceNotEnrolled);
      expect(result.requiresEnrollment, isTrue);
      expect(remoteDataSource.lastCheckDeviceUsername, '210049376');
    });

    test(
      'requestDeviceEnrollment convierte respuesta de enrolamiento',
      () async {
        final result = await repository.requestDeviceEnrollment(
          username: '210049376',
          device: device,
        );

        expect(result.code, 'OTP_SENT');
        expect(result.enrollmentId, 'enroll-001');
      },
    );

    test(
      'confirmDeviceEnrollment convierte respuesta final de enrolamiento',
      () async {
        final result = await repository.confirmDeviceEnrollment(
          enrollmentId: 'enroll-001',
          otp: '483921',
          username: '210049376',
        );

        expect(result.code, 'OK');
        expect(result.deviceIdHash, 'hash-final');
        expect(remoteDataSource.lastConfirmEnrollmentOtp, '483921');
      },
    );

    test('clearSession delega al datasource', () async {
      await repository.clearSession();

      expect(remoteDataSource.clearSessionCalled, isTrue);
    });
  });
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? lastLoginUsername;
  String? lastForgotPasswordEmail;
  String? lastResetPasswordOtp;
  String? lastCheckDeviceUsername;
  String? lastConfirmEnrollmentOtp;
  bool clearSessionCalled = false;

  @override
  Future<void> clearSession() async {
    clearSessionCalled = true;
  }

  @override
  Future<DeviceCheckResponseDto> checkDevice({
    required String username,
    required AppDeviceInfo device,
  }) async {
    lastCheckDeviceUsername = username;
    return const DeviceCheckResponseDto(
      code: 'DEVICE_NOT_ENROLLED',
      message: 'Dispositivo no enrolado',
      deviceIdHash: 'hash-check',
    );
  }

  @override
  Future<DeviceEnrollmentConfirmResponseDto> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  }) async {
    lastConfirmEnrollmentOtp = otp;
    return const DeviceEnrollmentConfirmResponseDto(
      code: 'OK',
      message: 'Dispositivo enrolado',
      deviceIdHash: 'hash-final',
    );
  }

  @override
  Future<AuthActionResponseDto> forgotPassword({required String email}) async {
    lastForgotPasswordEmail = email;
    return const AuthActionResponseDto(ok: true, message: 'OTP enviado');
  }

  @override
  Future<AuthUserDto> getCurrentUser() async {
    return const AuthUserDto(
      userId: 25,
      username: '210049376',
      email: 'persona@edomex.gob.mx',
      spId: 'SP001',
      status: 'ACTIVE',
      roles: ['ROLE_USER'],
    );
  }

  @override
  Future<LoginResponseDto> login({
    required String username,
    required String password,
  }) async {
    lastLoginUsername = username;
    return const LoginResponseDto(
      username: '210049376',
      userId: 25,
      message: 'Login correcto',
    );
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
    return const RegisterResponseDto(
      userId: 10,
      username: '210048332',
      status: 'ACTIVE',
      message: 'Registro exitoso',
    );
  }

  @override
  Future<DeviceEnrollmentRequestResponseDto> requestDeviceEnrollment({
    required String username,
    required AppDeviceInfo device,
  }) async {
    return const DeviceEnrollmentRequestResponseDto(
      code: 'OTP_SENT',
      message: 'Codigo enviado',
      enrollmentId: 'enroll-001',
    );
  }

  @override
  Future<AuthActionResponseDto> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    lastResetPasswordOtp = otp;
    return const AuthActionResponseDto(
      ok: true,
      message: 'Password actualizado',
    );
  }
}
