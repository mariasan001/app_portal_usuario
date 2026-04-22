import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/app/enrutador/auth_redirect.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/auth_user.dart';

void main() {
  group('redirectForAuth', () {
    const user = AuthUser(
      userId: 1,
      username: 'usuario',
      email: 'usuario@demo.com',
      spId: 'SP001',
      status: 'ACTIVE',
      roles: ['ROLE_USER'],
    );

    test('deja pasar rutas publicas mientras auth esta en unknown', () {
      expect(
        redirectForAuth(
          authState: const AuthState.unknown(),
          location: '/login',
        ),
        isNull,
      );
    });

    test(
      'manda a bienvenida si entra a zona privada mientras bootstrap corre',
      () {
        expect(
          redirectForAuth(
            authState: const AuthState.unknown(),
            location: '/home',
          ),
          '/bienvenida',
        );
      },
    );

    test('manda a login si no hay sesion y piden zona privada', () {
      expect(
        redirectForAuth(
          authState: const AuthState.unauthenticated(),
          location: '/home',
        ),
        '/login',
      );
    });

    test('deja pasar recuperacion si no hay sesion', () {
      expect(
        redirectForAuth(
          authState: const AuthState.unauthenticated(),
          location: '/recuperar',
        ),
        isNull,
      );
    });

    test('manda a home si ya hay sesion y abren login', () {
      expect(
        redirectForAuth(
          authState: const AuthState.authenticated(user),
          location: '/login',
        ),
        '/home',
      );
    });

    test('deja pasar zona privada si ya hay sesion', () {
      expect(
        redirectForAuth(
          authState: const AuthState.authenticated(user),
          location: '/perfil',
        ),
        isNull,
      );
    });
  });
}
