import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/RecuperarPasswordPage.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/nueva_contrasena_page.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/introduccion/ui/bienvenida_page.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/login/login_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/registro/registro_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/token/token_page.dart';


class EnrutadorApp {
  static final GoRouter router = GoRouter(
    initialLocation: '/bienvenida',
    routes: [
      GoRoute(
        path: '/bienvenida',
        builder: (context, state) => const BienvenidaPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroPage(),
      ),

      // ✅ OLVIDÉ CONTRASEÑA: 1) correo
      GoRoute(
        path: '/recuperar',
        builder: (context, state) => const RecuperarPasswordPage(),
      ),

      // ✅ TOKEN (MISMA PAGE): sirve para registro o recuperar
      GoRoute(
        path: '/token',
        builder: (context, state) {
          final extra = (state.extra as Map?) ?? {};

          // defaults por si entras directo
          final backRoute = (extra['backRoute'] ?? '/login') as String;
          final nextRoute = (extra['nextRoute'] ?? '/login') as String;

          // (opcional) para mostrar a qué correo se envió
          final email = (extra['email'] ?? '') as String;

          return TokenPage(
            backRoute: backRoute,
            nextRoute: nextRoute,
            email: email, // si tu TokenPage no lo tiene, lo quitas
          );
        },
      ),

      // ✅ OLVIDÉ CONTRASEÑA: 3) nueva contraseña
      GoRoute(
        path: '/nueva-contrasena',
        builder: (context, state) {
          final extra = (state.extra as Map?) ?? {};

          final email = (extra['email'] ?? '') as String;
          final token = (extra['token'] ?? '') as String;

          return NuevaContrasenaPage(
            email: email,
            token: token,
          );
        },
      ),
    ],
  );
}
