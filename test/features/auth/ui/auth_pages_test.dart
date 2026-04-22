import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/nueva_contrasena_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/recuperar_password_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/login/login_page.dart';
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
  group('Auth widget flows', () {
    testWidgets('LoginPage navega a home al iniciar sesion correctamente', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository();

      await _pumpAuthPage(
        tester,
        page: const LoginPage(),
        repository: repository,
      );

      await tester.enterText(find.byType(TextField).at(0), '210049376');
      await tester.enterText(find.byType(TextField).at(1), 'Secreto123');
      await tester.tap(find.text('Entrar a mi perfil'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('home-dest'), findsOneWidget);
    });

    testWidgets('LoginPage muestra error si las credenciales fallan', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository(
        loginErrorMessage: 'Credenciales invalidas.',
      );

      await _pumpAuthPage(
        tester,
        page: const LoginPage(),
        repository: repository,
      );

      await tester.enterText(find.byType(TextField).at(0), '210049376');
      await tester.enterText(find.byType(TextField).at(1), 'Incorrecta123');
      await tester.tap(find.text('Entrar a mi perfil'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Credenciales invalidas.'), findsOneWidget);
      expect(find.text('home-dest'), findsNothing);
    });

    testWidgets('RecuperarPasswordPage navega a token al enviar correo', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository();

      await _pumpAuthPage(
        tester,
        page: const RecuperarPasswordPage(),
        repository: repository,
      );

      await tester.enterText(find.byType(TextField).first, 'persona@demo.com');
      await tester.tap(find.text('Enviar codigo'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('token-dest'), findsOneWidget);
    });

    testWidgets('RecuperarPasswordPage muestra error si forgot falla', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository(
        forgotPasswordErrorMessage: 'No se pudo enviar el codigo.',
      );

      await _pumpAuthPage(
        tester,
        page: const RecuperarPasswordPage(),
        repository: repository,
      );

      await tester.enterText(find.byType(TextField).first, 'persona@demo.com');
      await tester.tap(find.text('Enviar codigo'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No se pudo enviar el codigo.'), findsOneWidget);
      expect(find.text('token-dest'), findsNothing);
    });

    testWidgets('TokenPage de recuperacion avanza al completar 6 digitos', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository();

      await _pumpAuthPage(
        tester,
        page: const TokenPage(
          backRoute: '/login',
          nextRoute: '/nueva-contrasena',
          flow: 'password-reset',
          email: 'persona@demo.com',
        ),
        repository: repository,
      );

      await tester.enterText(find.byType(TextFormField).first, '483921');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('nueva-dest'), findsOneWidget);
    });

    testWidgets('NuevaContrasenaPage vuelve a login al cambiar password', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository();

      await _pumpAuthPage(
        tester,
        page: const NuevaContrasenaPage(
          email: 'persona@demo.com',
          token: '483921',
        ),
        repository: repository,
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'NuevaPass#2026',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'NuevaPass#2026',
      );
      await tester.tap(find.text('Cambiar contrasena'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('login-dest'), findsOneWidget);
    });

    testWidgets('NuevaContrasenaPage muestra error si reset falla', (
      tester,
    ) async {
      final repository = WidgetTestAuthRepository(
        resetPasswordErrorMessage: 'El codigo ya expiro.',
      );

      await _pumpAuthPage(
        tester,
        page: const NuevaContrasenaPage(
          email: 'persona@demo.com',
          token: '483921',
        ),
        repository: repository,
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'NuevaPass#2026',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'NuevaPass#2026',
      );
      await tester.tap(find.text('Cambiar contrasena'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('El codigo ya expiro.'), findsOneWidget);
      expect(find.text('login-dest'), findsNothing);
    });

    testWidgets(
      'Smoke: flujo completo de recuperacion avanza entre pantallas',
      (tester) async {
        final repository = WidgetTestAuthRepository();

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
                  nextRoute:
                      extra['nextRoute'] as String? ?? '/nueva-contrasena',
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
              builder: (context, state) =>
                  const Scaffold(body: Text('login-dest')),
            ),
          ],
        );

        await _pumpRouter(tester, router: router, repository: repository);

        await tester.enterText(
          find.byType(TextField).first,
          'persona@demo.com',
        );
        await tester.tap(find.text('Enviar codigo'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Confirma tu codigo'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).first, '483921');
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Crea tu nueva contrasena'), findsOneWidget);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'NuevaPass#2026',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'NuevaPass#2026',
        );
        await tester.tap(find.text('Cambiar contrasena'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('login-dest'), findsOneWidget);
      },
    );
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

Future<void> _pumpAuthPage(
  WidgetTester tester, {
  required Widget page,
  required WidgetTestAuthRepository repository,
}) async {
  final router = GoRouter(
    initialLocation: '/current',
    routes: [
      GoRoute(path: '/current', builder: (context, state) => page),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('home-dest')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login-dest')),
      ),
      GoRoute(
        path: '/registro',
        builder: (context, state) =>
            const Scaffold(body: Text('registro-dest')),
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) => const Scaffold(body: Text('token-dest')),
      ),
      GoRoute(
        path: '/nueva-contrasena',
        builder: (context, state) => const Scaffold(body: Text('nueva-dest')),
      ),
      GoRoute(
        path: '/recuperar',
        builder: (context, state) =>
            const Scaffold(body: Text('recuperar-dest')),
      ),
    ],
  );

  await _pumpRouter(tester, router: router, repository: repository);
}

Future<void> _pumpRouter(
  WidgetTester tester, {
  required GoRouter router,
  required WidgetTestAuthRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        deviceMetadataCollectorServiceProvider.overrideWithValue(
          _WidgetTestDeviceMetadataCollector(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await tester.pump();
}

class _WidgetTestDeviceMetadataCollector implements DeviceMetadataCollector {
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

class WidgetTestAuthRepository implements AuthRepository {
  WidgetTestAuthRepository({
    this.loginErrorMessage,
    this.forgotPasswordErrorMessage,
    this.resetPasswordErrorMessage,
    this.deviceCheckResult = const DeviceCheckResult(
      code: DeviceCheckCode.ok,
      rawCode: 'OK',
      message: 'Dispositivo reconocido',
    ),
  });

  final String? loginErrorMessage;
  final String? forgotPasswordErrorMessage;
  final String? resetPasswordErrorMessage;
  final DeviceCheckResult deviceCheckResult;

  int _getCurrentUserCalls = 0;

  @override
  Future<void> clearSession() async {}

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
    if (forgotPasswordErrorMessage != null) {
      throw ApiException(message: forgotPasswordErrorMessage!);
    }

    return const AuthActionResult(ok: true, message: 'OTP enviado al correo');
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    _getCurrentUserCalls++;
    if (_getCurrentUserCalls == 1) {
      throw ApiException(message: 'Sin sesion');
    }

    return const AuthUser(
      userId: 25,
      username: '210049376',
      email: 'persona@demo.com',
      spId: 'SP001',
      status: 'ACTIVE',
      roles: ['ROLE_USER'],
    );
  }

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    if (loginErrorMessage != null) {
      throw ApiException(message: loginErrorMessage!);
    }

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
    if (resetPasswordErrorMessage != null) {
      throw ApiException(message: resetPasswordErrorMessage!);
    }

    return const AuthActionResult(ok: true, message: 'Password actualizado');
  }
}
