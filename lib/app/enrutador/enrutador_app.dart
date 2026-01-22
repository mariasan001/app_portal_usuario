import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/introduccion/ui/bienvenida_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/login/login_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/registro/registro_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/token/token_page.dart';

// ⚠️ Recomendación: renombra carpeta a cambio_contrasena para evitar %C3%B1
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/RecuperarPasswordPage.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/nueva_contrasena_page.dart';

// ✅ Shell

// ✅ Contenido de tabs
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/inicio_tab.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/servicios_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/shell/app_shell.dart';

class EnrutadorApp {
  static final GoRouter router = GoRouter(
    initialLocation: '/bienvenida',
    routes: [
      // ------------------ INTRO / AUTH (sin AppShell) ------------------
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
      GoRoute(
        path: '/recuperar',
        builder: (context, state) => const RecuperarPasswordPage(),
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) {
          final extra = (state.extra as Map?) ?? {};

          final backRoute = (extra['backRoute'] ?? '/login') as String;
          final nextRoute = (extra['nextRoute'] ?? '/home') as String; // ✅ aquí mejor /home
          final email = (extra['email'] ?? '') as String;

          return TokenPage(
            backRoute: backRoute,
            nextRoute: nextRoute,
            email: email,
          );
        },
      ),
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

      // ------------------ APP (con AppShell siempre) ------------------
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const InicioTab(),
          ),
          GoRoute(
            path: '/servicios',
            builder: (context, state) => const ServiciosPage(),
          ),
          GoRoute(
            path: '/tramites',
            builder: (context, state) => const _TramitesPage(),
          ),
          GoRoute(
            path: '/recibos',
            builder: (context, state) => const _RecibosPage(),
          ),
        ],
      ),
    ],
  );
}

// Placeholders rápidos (para que NO se vea vacío)
class _TramitesPage extends StatelessWidget {
  const _TramitesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mis trámites (placeholder)'));
  }
}

class _RecibosPage extends StatelessWidget {
  const _RecibosPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Recibos (placeholder)'));
  }
}
