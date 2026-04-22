import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/ayuda/ayuda_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/ui/pages/documento_detalle_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/ui/pages/documentos_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/inicio_tab.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/introduccion/ui/bienvenida_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/citas_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/recibos_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/servicios_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/shell/app_shell.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/perfil/ui/perfil_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/ui/widgets/servicio_proceso_page.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/ui/pages/login_page.dart';
import 'package:portal_servicios_usuario/features/auth/ui/pages/nueva_contrasena_page.dart';
import 'package:portal_servicios_usuario/features/auth/ui/pages/recuperar_password_page.dart';
import 'package:portal_servicios_usuario/features/auth/ui/pages/registro_page.dart';
import 'package:portal_servicios_usuario/features/auth/ui/pages/token_page.dart';

import 'auth_redirect.dart';

class EnrutadorApp {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final refreshListenableProvider = Provider<ValueNotifier<int>>((ref) {
    final notifier = ValueNotifier<int>(0);

    ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifier.value++;
    });

    ref.onDispose(notifier.dispose);
    return notifier;
  });

  static final routerProvider = Provider<GoRouter>((ref) {
    final refreshListenable = ref.watch(refreshListenableProvider);

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/bienvenida',
      debugLogDiagnostics: true,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authState = ref.read(authControllerProvider);
        return redirectForAuth(authState: authState, location: state.uri.path);
      },
      errorBuilder: (context, state) {
        return Scaffold(
          body: Center(
            child: Text(
              'Ruta no encontrada: ${state.uri}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/bienvenida',
          builder: (context, state) => const BienvenidaPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
            final nextRoute = (extra['nextRoute'] ?? '/home') as String;
            final email = (extra['email'] ?? '') as String;
            final flow = (extra['flow'] ?? 'password-reset') as String;
            final username = (extra['username'] ?? '') as String;
            final enrollmentId = (extra['enrollmentId'] ?? '') as String;

            return TokenPage(
              backRoute: backRoute,
              nextRoute: nextRoute,
              email: email,
              flow: flow,
              username: username,
              enrollmentId: enrollmentId,
            );
          },
        ),
        GoRoute(
          path: '/nueva-contrasena',
          builder: (context, state) {
            final extra = (state.extra as Map?) ?? {};
            final email = (extra['email'] ?? '') as String;
            final token = (extra['token'] ?? '') as String;
            final backRoute = (extra['backRoute'] ?? '/token') as String;

            return NuevaContrasenaPage(
              email: email,
              token: token,
              backRoute: backRoute,
            );
          },
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: InicioTab()),
            ),
            GoRoute(
              path: '/servicios',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ServiciosPage()),
            ),
            GoRoute(
              path: '/tramites',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TramitesPage()),
            ),
            GoRoute(
              path: '/recibos',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: RecibosPage()),
            ),
            GoRoute(
              path: '/servicios/:tipo/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ServicioProcesoPage(servicioId: id);
              },
            ),
            GoRoute(
              path: '/perfil',
              builder: (context, state) => const PerfilPage(),
            ),
            GoRoute(
              path: '/documentos',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DocumentosPage()),
            ),
            GoRoute(
              path: '/documentos/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return DocumentoDetallePage(documentoId: id);
              },
            ),
            GoRoute(
              path: '/ayuda',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AyudaSoportePage()),
            ),
          ],
        ),
      ],
    );
  });
}
