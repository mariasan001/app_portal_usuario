import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/nueva_contrasena_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/recuperar_password_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/token/token_page.dart';
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke auth: recuperacion completa navega hasta login', (
    tester,
  ) async {
    final repository = _SmokeAuthRepository();
    final router = GoRouter(
      initialLocation: '/recuperar',
      routes: [
        GoRoute(
          path: '/recuperar',
          builder: (context, state) => const RecuperarPasswordPage(),
        ),
        GoRoute(
          path: '/token',
          builder: (context, state) {
            final extra = _readExtraMap(state);
            return TokenPage(
              backRoute: extra['backRoute'] as String? ?? '/login',
              nextRoute: extra['nextRoute'] as String? ?? '/nueva-contrasena',
              flow: extra['flow'] as String? ?? 'password-reset',
              email: extra['email'] as String?,
              username: extra['username'] as String? ?? '',
              enrollmentId: extra['enrollmentId'] as String? ?? '',
            );
          },
        ),
        GoRoute(
          path: '/nueva-contrasena',
          builder: (context, state) {
            final extra = _readExtraMap(state);
            return NuevaContrasenaPage(
              email: extra['email'] as String? ?? '',
              token: extra['token'] as String? ?? '',
              backRoute: extra['backRoute'] as String? ?? '/token',
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('login-dest')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          deviceMetadataCollectorServiceProvider.overrideWithValue(
            _SmokeDeviceMetadataCollector(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'persona@demo.com');
    await tester.tap(find.text('Enviar codigo'));
    await tester.pumpAndSettle();

    expect(find.text('Confirma tu codigo'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '483921');
    await tester.pumpAndSettle();

    expect(find.text('Crea tu nueva contrasena'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'NuevaPass#2026');
    await tester.enterText(find.byType(TextFormField).at(1), 'NuevaPass#2026');
    await tester.tap(find.text('Cambiar contrasena'));
    await tester.pumpAndSettle();

    expect(find.text('login-dest'), findsOneWidget);
  });
}

Map<String, dynamic> _readExtraMap(GoRouterState state) {
  final extra = state.extra;
  if (extra is Map<String, dynamic>) {
    return extra;
  }

  if (extra is Map<Object?, Object?>) {
    return extra.cast<String, dynamic>();
  }

  return const {};
}

class _SmokeDeviceMetadataCollector implements DeviceMetadataCollector {
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

class _SmokeAuthRepository implements AuthRepository {
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
    return const AuthActionResult(ok: true, message: 'OTP enviado al correo');
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
